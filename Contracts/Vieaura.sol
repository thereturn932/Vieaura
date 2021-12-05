//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
Import contract interfaces
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "./IContracts/IVIA.sol";
import "./IContracts/LiquidityGaugeInterface.sol";
import "./IContracts/IDepositZap.sol";
import "./IContracts/MinterInterface.sol";
import "hardhat/console.sol";




/// @author TheReturn932
/// @title Vieaura Challenge
/** 
@notice Deposits a certain amount of DAI of user into 3pool then deposits LP token got from 
 3pool into liquidity gauge. Users can harvest their CRV tokens and withdraw DAI back to their acounts.
*/
contract Vieaura {
    using SafeMath for uint;

    //Define Events
    event Deposit(address indexed _from, uint _returnedLP, uint _depositedValue);
    event Withdraw(address indexed _from, uint _sentLP, uint _withdrawnDAI);
    event Harvest(address indexed _from, uint harvestedAmount);

    //Addresses of the contracts we will use 
    address constant public _VIATokenAddress = address(0xC9a43158891282A2B1475592D5719c001986Aaec);
    address constant public _3poolAddress = address(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    address constant public _daiAddress = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant public _liquidityGaugeAddress = address(0xbFcF63294aD7105dEa65aA58F8AE5BE2D9d0952A);
    address constant public _LPTokenAddress = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
    address constant public _minterAddress = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    address constant public _depositZapAdress = address(0xA79828DF1850E8a3A3064576f380D90aECDD3359);
    
    //Token and Pool classes are created
    IERC20 public immutable _daiToken = IERC20(_daiAddress);
    IVIA public _VIAToken = IVIA(_VIATokenAddress);
    IERC20 public immutable _LPtoken = IERC20(_LPTokenAddress);
    IDepositZap public _DepositContract = IDepositZap(_depositZapAdress);
    LiquidityGaugeInterface public immutable _liquidityGauge = LiquidityGaugeInterface(_liquidityGaugeAddress);
    MinterInterface public immutable _minter = MinterInterface(_minterAddress);

    mapping(address => bool) private _approved;
    mapping(address => bool) private _created;
    mapping(address => uint) private _approvedAmount;
    mapping(address => uint) private _LPAmountOfUser;
    mapping(address => uint) private _unclaimedHarvest;

    uint public _VIATokenSupply;
    address[] users;

    address owner;

    constructor() {
        
        owner = msg.sender;
        console.log("Contract is started");
    }

    /// @dev might be used in future improvements
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function ChangeVIATokenAddress(address _newAddress) external onlyOwner{
        _VIAToken = IVIA(_newAddress);
    }

    /// @dev gets allowance for transfer from msg.sender
    function approve(uint256 underlyingAmount) external {
        _daiToken.approve(address(this), underlyingAmount);
        _approved[msg.sender] = true;
        _approvedAmount[msg.sender] = underlyingAmount;
    }

    /**
    @dev deposits underlyingAmount of DAI into 3pool, then deposits LP tokens into liquidity gauge.
    VIA Tokens are given to account LP tokens of user.
     */  
    function deposit(uint256 underlyingAmount) external {
        console.log("Works till here_1");
         require(_approved[msg.sender] && _approvedAmount[msg.sender] >= underlyingAmount, "Not approved or approved amount is less than requested");
         console.log("Works till here_2");
         uint oldLPAmount = _LPtoken.balanceOf(address(this));
         console.log("Works till here_3");
         _daiToken.transferFrom(msg.sender, address(this), underlyingAmount);
         console.log("Works till here_3");
         _DepositContract.add_liquidity(_3poolAddress, [underlyingAmount, 0, 0], 0);
         console.log("Works till here_4");
         uint mintedLP = _LPtoken.balanceOf(address(this)) - oldLPAmount;
         console.log("Works till here_5");
         _LPAmountOfUser[msg.sender] += mintedLP;
         console.log("Works till here_6");
         _liquidityGauge.deposit(mintedLP);
         console.log("Works till here_7");
         _VIAToken.mint(msg.sender,mintedLP);
         console.log("Works till here_8");
         if (_created[msg.sender] == false) {
             _created[msg.sender] = true;
             users.push(msg.sender);
         }
         console.log("Works till here_9");
         _approved[msg.sender] = false;
         console.log("Works till here_10");
         _approvedAmount[msg.sender] = 0;
         console.log("Works till here_10");
         emit Deposit(msg.sender, mintedLP, underlyingAmount);
    }

    /**
    @dev gets LP tokens from liquidity gauge and withdraw lpAmount of LP token 3pool,
    VIA Tokens are given to account LP tokens of user.
     */  
    function withdraw(uint256 lpAmount) external {
        require(_VIAToken.balanceOf(msg.sender) >= lpAmount);
        _VIAToken.approve(msg.sender, lpAmount);
        _liquidityGauge.withdraw(lpAmount);
        uint oldBalanceDAI = _LPtoken.balanceOf(address(this));
        _DepositContract.remove_liquidity(_3poolAddress, lpAmount, 0, 0);
        uint currentBalanceDAI = _LPtoken.balanceOf(address(this));
        uint userBalanceDAI = currentBalanceDAI - oldBalanceDAI;
        _daiToken.transfer(msg.sender, userBalanceDAI);
        harvest();
        _VIAToken.burnFrom(msg.sender, lpAmount);
        _LPAmountOfUser[msg.sender] -= lpAmount;
        emit Withdraw(msg.sender, lpAmount, userBalanceDAI);
    } 
    /**
    @dev claims CRV rewards of user from liquidity gauge
     */  
    function harvest() public {
        uint oldBalanceCRV = _LPtoken.balanceOf(address(this));
        _minter.mint(_liquidityGaugeAddress);
        uint currentBalanceCRV = _LPtoken.balanceOf(address(this));
        uint unclaimedBalanceCRV = currentBalanceCRV - oldBalanceCRV;
        for (uint i = 0; i< users.length; i++) {
            _unclaimedHarvest[users[i]] += unclaimedBalanceCRV.mul(_VIAToken.balanceOf(users[i]).div(_VIAToken.totalSupply()));
        }
        swapExactInputSingle(_unclaimedHarvest[msg.sender]);
        uint harvested = _unclaimedHarvest[msg.sender];
        _unclaimedHarvest[msg.sender] = 0;
        emit Harvest(msg.sender, harvested);
    }

    function exchangeRate() public pure returns (uint8){
        /**
        returns the exchange rate between the underlying
        token (DAI) and the LP token 
         */
        return 1;
    }

    uint24 public constant poolFee = 3000;

    function swapExactInputSingle(uint256 amountIn) internal returns (uint256 amountOut) {
    // Approve the router to spend DAI.
    TransferHelper.safeApprove(_daiAddress, address(swapRouter), amountIn);

            // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: _LPTokenAddress,
                tokenOut: _daiAddress,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
}