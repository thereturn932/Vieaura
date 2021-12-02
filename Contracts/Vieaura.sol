//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";


contract Vieaura {
    constructor() {
        console.log("Contract is started");
    }

    function deposit(uint256 underlyingAmount) external {
        /**
        Deposits "underlyingAmount" of DAI token and recieves LP
         */
        
        
    }

    function withdraw(uint256 lpAmount) external {
        /**
        Withdraws "lpAmount" of DAI token and recieves LP

         */
    } 

    function harvest() external {
        /**
        claims the accumulated CRV rewards from Curve and
        converts them to DAI 
         */
    }

    function exchangeRate() public view {
        /**
        returns the exchange rate between the underlying
        token (DAI) and the LP token 
         */
    }
}