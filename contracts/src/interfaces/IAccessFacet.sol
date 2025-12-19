// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IAccessFacet
/// @notice Рабата с whitelist

interface IAccessFacet {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event AddressAddedToWhitelist(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTION
    //////////////////////////////////////////////////////////////*/
    /// @notice  Аккаунт в Whitelist?
    function isWhitelisted(address account) external view returns (bool);

    /// @notice Получить адрес админа
    function getAdmin() external view returns (address);

    function getWhitelistedAddresses() external view returns (address[] memory);

    /*//////////////////////////////////////////////////////////////
                             ADMIN FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @notice добавление в whitelist
    function addToWhitelist(address account) external;

    /// @notice удаление из whitelist
    function removeFromWhitelist(address account) external;
}
