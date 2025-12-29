// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IVaultFacet
/// @notice Interface for working with Vault
interface IVaultFacet {
    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @notice address  of the underlying asset
    function asset() external view returns (address);

    /// @notice balance of users shares
    function balanceOf(address account) external view returns (uint256);

    /// @notice convert shares to assets
    function convertToAssets(
        uint256 shares
    ) external view returns (uint256 assets);

    /// @notice convert assets to shares
    function convertToShares(
        uint256 assets
    ) external view returns (uint256 shares);

    /// @notice total assets (underlying tokens) in the Vault
    function totalAssets() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                             USER FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @notice deposits tokens to Vault
    /// @return shares
    function deposit(
        uint256 assets,
        address receiver
    ) external returns (uint256 shares);

    /// @notice withdraw assets from Vault
    /// @return shares number of shares which has been burn
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);
}
