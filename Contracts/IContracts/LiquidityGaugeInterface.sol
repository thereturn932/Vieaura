// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LiquidityGaugeInterface    {
    function deposit(uint _value) external;
    function deposit(uint _value, address addr) external;
    function withdraw(uint _value) external;
    function set_approve_deposit(address addr, bool can_deposit) external;
}