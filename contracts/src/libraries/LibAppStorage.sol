// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct AppStorage {
    /*//////////////////////////////////////////////////////////////
                             VAULT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice balance of shares each user
    mapping(address => uint256) shares;
    /// @notice  TVL (token underlying)
    uint256 totalAssets;
    /// @notice  total amount of shares
    uint256 totalShares;
    /// @notice token(underlying) address
    address tokenAssetAddress;
    /// @notice decimals for shares
    uint8 decimals;
    /// @notice initialization flag
    bool initialized;
    /// @notice status for reentracy guard
    uint256 status;
    /*//////////////////////////////////////////////////////////////
                            ACCESS STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice  users whitelist
    mapping(address => bool) whitelist;
    /// @notice admin address
    address admin;
    /// @notice the list of all address which located in whitelist
    address[] whitelistedAddresses;
    /// @notice address index in whitelistedAddresses array
    mapping(address => uint256) whitelistIndex;
}

library LibAppStorage {
    function appStorage() internal pure returns (AppStorage storage s) {
        bytes32 position = keccak256("volt.app.storage");
        assembly {
            s.slot := position
        }
    }
}
