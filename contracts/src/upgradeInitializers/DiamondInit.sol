// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";
import {
    IERC20Metadata
} from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/IERC20Metadata.sol";

/// @title DiamondInit
/// @notice Инициализация Vault при первом деплое
contract DiamondInit {
    /// @notice Инициализирует Vault
    /// @param _tokenAssetAddress Адрес токена
    /// @param _admin Адрес администратора whitelist
    function init(address _tokenAssetAddress, address _admin) external {
        AppStorage storage s = LibAppStorage.appStorage();

        require(!s.initialized, "Already initialized");
        require(_tokenAssetAddress != address(0), "DiamondInit: zero asset");
        require(_admin != address(0), "DiamondInit: zero admin");

        s.tokenAssetAddress = _tokenAssetAddress;
        s.admin = _admin;
        s.decimals = IERC20Metadata(_tokenAssetAddress).decimals();
        s.initialized = true;
        s.whitelist[_admin] = true;
    }
}
