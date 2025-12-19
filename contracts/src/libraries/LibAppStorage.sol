// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct AppStorage {
    /*//////////////////////////////////////////////////////////////
                             VAULT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Баланас долей каждого пользователя
    mapping(address => uint256) shares;
    /// @notice Всего активов (TVL)
    uint256 totalAssets;
    /// @notice Всего долей
    uint256 totalShares;
    /// @notice Адрес токена
    address tokenAssetAddress;
    /// @notice Decimals для shares
    uint8 decimals;
    /// @notice Флаг инициализации
    bool initialized;
    /*//////////////////////////////////////////////////////////////
                            ACCESS STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice  Whitelist пользователей
    mapping(address => bool) whitelist;
    /// @notice  Список всех адресов которые находятся в whitelist
    address[] whitelistedAddresses;
    /// @notice Индекс адреса в массиве whitelistedAddresses
    mapping(address => uint256) whitelistIndex;
    /// @notice адрес админа
    address admin;
}

library LibAppStorage {
    function appStorage() internal pure returns (AppStorage storage s) {
        bytes32 position = keccak256("volt.app.storage");
        assembly {
            s.slot := position
        }
    }
}
