// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Interface3Pool {
    function add_liquidity(uint[3] memory amounts, uint min_mint_amount) external;
    function remove_liquidity(uint _amount, uint[3] memory min_amounts) external;
    function get_virtual_price() external view returns (uint);
    
}
