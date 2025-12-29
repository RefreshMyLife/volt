// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IDiamondLoupe
/// @notice Interface for viewing facets
interface IDiamondLoupe {
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice get all facets
    function facets() external view returns (Facet[] memory facets_);

    /// @notice get all function from facet
    function facetFunctionSelectors(
        address _facet
    ) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice get all address of facets
    function facetAddresses()
        external
        view
        returns (address[] memory facetAddresses_);

    /// @notice find facet by function selector
    function facetAddress(
        bytes4 _functionSelector
    ) external view returns (address facetAddress_);
}
