// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVIA is IERC20{
    //To
    function mint(address to, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function AddMinter(address _newMinter) external;
}
