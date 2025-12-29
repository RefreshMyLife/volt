// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IAccessFacet
/// @notice Interect with whitelist

interface IAccessFacet {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event AddressAddedToWhitelist(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTION
    //////////////////////////////////////////////////////////////*/
    /// @notice  is the account in whitelist
    function isWhitelisted(address account) external view returns (bool);

    /// @notice get admin address
    function getAdmin() external view returns (address);

    /// @notice get all address which located in whitelitst
    function getWhitelistedAddresses() external view returns (address[] memory);

    /*//////////////////////////////////////////////////////////////
                             ADMIN FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @notice add  account to whitelist
    function addToWhitelist(address account) external;

    /// @notice romove account from whitelist
    function removeFromWhitelist(address account) external;
}
