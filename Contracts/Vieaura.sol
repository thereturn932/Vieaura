//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "./IContracts/IVIA.sol";
import "hardhat/console.sol";

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}


interface LiquidityGaugeInterface    {
    function deposit(uint _value) external;
    function deposit(uint _value, address addr) external;
    function withdraw(uint _value) external;
    function set_approve_deposit(address addr, bool can_deposit) external;
}

interface Interface3Pool {
    function add_liquidity(uint[3] memory amounts, uint min_mint_amount) external;
    function remove_liquidity(uint _amount, uint[3] memory min_amounts) external;
    function get_virtual_price() external view returns (uint);
}

interface MinterInterface {
    function mint(address gauge_addr) external;
}


contract Vieaura {
    //Addresses of the contracts we will use 
    address constant public _VIATokenAddress = address(0xe8D2A1E88c91DCd5433208d4152Cc4F399a7e91d);
    address constant public _3poolAddress = address(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    address constant public _daiAddress = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant public _liquidityGaugeAddress = address(0xbFcF63294aD7105dEa65aA58F8AE5BE2D9d0952A);
    address constant public _LPTokenAddress = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
    address constant public _minterAddress = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address constant public _uniswapRouter = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    ISwapRouter public immutable swapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    
    //Token and Pool classes are created
    IERC20 public immutable _daiToken = IERC20(_daiAddress);
    IVIA public immutable _VIAToken = IVIA(_VIATokenAddress);
    IERC20 public immutable _LPtoken = IERC20(_LPTokenAddress);
    Interface3Pool public immutable _3poolContract = Interface3Pool(_3poolAddress);
    LiquidityGaugeInterface public immutable _liquidityGauge = LiquidityGaugeInterface(_liquidityGaugeAddress);
    MinterInterface public immutable _minter = MinterInterface(_minterAddress);

    mapping(address => bool) private _approved;
    mapping(address => uint) private _approvedAmount;
    mapping(address => uint) private _LPAmountOfUser;
    uint public _LPTokenInContract;

    address owner;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        console.log("Contract is started");
    }

    function Approve(uint256 underlyingAmount) external {
        /**
        Get allowance for transfer
         */
        _daiToken.approve(msg.sender, underlyingAmount);
        _approved[msg.sender] = true;
        _approvedAmount[msg.sender] = underlyingAmount;
    }

    function deposit(uint256 underlyingAmount) external {
        /**
        Deposits "underlyingAmount" of DAI token and recieves LP
         */
         require(_approved[msg.sender] && _approvedAmount[msg.sender] >= underlyingAmount);
         _3poolContract.add_liquidity([underlyingAmount, 0, 0], 0);
         _LPAmountOfUser[msg.sender] += _LPtoken.balanceOf(address(this));
         _liquidityGauge.deposit(_LPtoken.balanceOf(address(this)));
         _VIAToken.mint(msg.sender,_LPAmountOfUser[msg.sender]);
         _approved[msg.sender] = false;
         _approvedAmount[msg.sender] = 0;
    }

    function withdraw(uint256 lpAmount) external {
        /**
        Withdraws "lpAmount" of DAI token and recieves LP

         */
        require(_VIAToken.balanceOf(msg.sender) >= lpAmount);
        _VIAToken.approve(msg.sender, lpAmount);
        uint[3] memory minAmount = [uint256(0),uint256(0),uint256(0)];
        _liquidityGauge.withdraw(lpAmount);
        uint oldBalanceDAI = _LPtoken.balanceOf(address(this));
        _3poolContract.remove_liquidity(lpAmount, minAmount);
        uint currentBalanceDAI = _LPtoken.balanceOf(address(this));
        uint userBalanceDAI = currentBalanceDAI - oldBalanceDAI;
        _daiToken.transfer(msg.sender, userBalanceDAI);
        _VIAToken.burnFrom(msg.sender, lpAmount);
    } 

    function harvest() external {
        /**
        claims the accumulated CRV rewards from Curve and
        converts them to DAI 
         */
        uint oldBalanceCRV = _LPtoken.balanceOf(address(this));
        _minter.mint(_liquidityGaugeAddress);
        uint currentBalanceCRV = _LPtoken.balanceOf(address(this));
        uint userBalanceCRV = currentBalanceCRV - oldBalanceCRV;
        swapExactInputSingle(userBalanceCRV);
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