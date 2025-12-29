// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin-contracts-5.3.0/token/ERC20/ERC20.sol";

/// @notice Mock token for tests
contract MockERC20 is ERC20 {
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_
    ) ERC20(name, symbol) {
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /// @notice mint token every one (for tests)
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
