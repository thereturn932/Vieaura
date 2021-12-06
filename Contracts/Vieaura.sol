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

interface Interface3Pool {
    function add_liquidity(uint[3] memory amounts, uint min_mint_amount) external;
    function remove_liquidity(uint _amount, uint[3] memory min_amounts) external;
    function get_virtual_price() external view returns (uint);
    
}


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
    

    Interface3Pool public immutable _3pool = Interface3Pool(_3poolAddress);
    //Token and Pool classes are created
    IERC20 public immutable _daiToken = IERC20(_daiAddress);
    IVIA public _VIAToken = IVIA(_VIATokenAddress);
    IERC20 public immutable _LPtoken = IERC20(_LPTokenAddress);
    IDepositZap public _DepositContract = IDepositZap(_depositZapAdress);
    LiquidityGaugeInterface public immutable _liquidityGauge = LiquidityGaugeInterface(_liquidityGaugeAddress);
    MinterInterface public immutable _minter = MinterInterface(_minterAddress);

    mapping(address => bool) private _created;
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

    /**
    @dev changes VIA token address for _VIAToken

    @param _newAddress: new address of VIA Token
     */
    function ChangeVIATokenAddress(address _newAddress) external onlyOwner{
        _VIAToken = IVIA(_newAddress);
    }

    /**
    @dev deposits underlyingAmount of DAI into 3pool, then deposits LP tokens into liquidity gauge.
    VIA Tokens are given to account LP tokens of user. 
    @param underlyingAmount: amount of DAI to be deposited
     */  
    function deposit(uint256 underlyingAmount) external {
        /// Harvest current CRV rate to reset CRV weight calculation currently in gauge
        harvest();
        /// Get current LP token balance of the address to calculate minted amount by substracting new amount
        uint oldLPAmount = _LPtoken.balanceOf(address(this));
        /// transfer DAI to contract then send it to 3pool
        _daiToken.transferFrom(msg.sender, address(this), underlyingAmount);
        _daiToken.approve(_3poolAddress, underlyingAmount);
        _3pool.add_liquidity([underlyingAmount, 0, 0], 0);

        /// Mint VIA Token and send it to user
        uint mintedLP = _LPtoken.balanceOf(address(this)).sub(oldLPAmount);
        _LPAmountOfUser[msg.sender] += mintedLP;
        _LPtoken.approve(_liquidityGaugeAddress,mintedLP);
        _liquidityGauge.deposit(mintedLP);
        _VIAToken.mint(msg.sender,mintedLP);

        /// If user is new add it user array
        if (_created[msg.sender] == false) {
             _created[msg.sender] = true;
             users.push(msg.sender);
         }
         emit Deposit(msg.sender, mintedLP, underlyingAmount);
    }

    /**
    @dev gets LP tokens from liquidity gauge and withdraw lpAmount of LP token 3pool,
    VIA Tokens are given to account LP tokens of user.

    @param lpAmount: amount of VIA Token to exchanged for DAI
     */  
    function withdraw(uint256 lpAmount) external {
        /// Check if user has enough lp and allowance is larger or equal to requested lp amount.
        require(_VIAToken.balanceOf(msg.sender) >= lpAmount && _VIAToken.allowance(msg.sender, address(this)) >= lpAmount);
        ///Withdraw lp from gauge, then withdraw DAI from pool.
        _liquidityGauge.withdraw(lpAmount);
        /// Sends the difference between old DAI amount and new DAI amount to user.
        uint oldBalanceDAI = _daiToken.balanceOf(address(this));
        _3pool.remove_liquidity(lpAmount, [uint256(0),uint256(0),uint256(0)]);
        uint currentBalanceDAI = _daiToken.balanceOf(address(this));
        uint userBalanceDAI = currentBalanceDAI.sub(oldBalanceDAI);
        _daiToken.transfer(msg.sender, userBalanceDAI);
        /// Harvests remaining amount to user
        harvest();
        /// Burns the tokens of the user.
        _VIAToken.burnFrom(msg.sender, lpAmount);
        _LPAmountOfUser[msg.sender].sub(lpAmount);
        emit Withdraw(msg.sender, lpAmount, userBalanceDAI);
    } 
    /**
    @dev claims CRV rewards of user from liquidity gauge
     */  
    function harvest() public {
        /// Difference between old and new CRV balance distrubuted between current LP participants of this contract.
        uint oldBalanceCRV = _LPtoken.balanceOf(address(this));
        _minter.mint(_liquidityGaugeAddress);
        uint currentBalanceCRV = _LPtoken.balanceOf(address(this));
        uint unclaimedBalanceCRV = currentBalanceCRV.sub(oldBalanceCRV);
        for (uint i = 0; i< users.length; i++) {
            _unclaimedHarvest[users[i]] += unclaimedBalanceCRV.mul(_VIAToken.balanceOf(users[i]).div(_VIAToken.totalSupply()));
        }
        /// @dev can't use require because this function also called in withdraw(). If this function gets reverted it withdraw() & deposit() also fails.
        if(_unclaimedHarvest[msg.sender] != 0){
            /// Swaps CRV with DAI and sends it directly to user
            swapExactInputSingle(_unclaimedHarvest[msg.sender]);
            uint harvested = _unclaimedHarvest[msg.sender];
            _unclaimedHarvest[msg.sender] = 0;
            emit Harvest(msg.sender, harvested);
        }
        
    }

    /**
    @dev returns the exchange rate between DAI and LP
     */
    function exchangeRate() public view returns (uint){
        return _3pool.get_virtual_price();
    }

    uint24 public constant poolFee = 3000;

    /// @dev swaps CRV with DAI sends it to user
    function swapExactInputSingle(uint256 amountIn) internal returns (uint256 amountOut) {
        /// first we need to approve swap contract to spend CRV in this contract
        TransferHelper.safeApprove(_LPTokenAddress, address(swapRouter), amountIn);

        /// Parameters craeted for swap
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

        /// Parameters send to swapRouter for swap
        amountOut = swapRouter.exactInputSingle(params);
    }
}