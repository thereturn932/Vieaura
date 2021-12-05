// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDepositZap {
    function add_liquidity(address _pool, uint[3] memory _deposit_amounts, uint _min_mint_amount) external;
    function remove_liquidity(address _pool, uint _burn_amount, int128 i, uint _min_amount) external;
}