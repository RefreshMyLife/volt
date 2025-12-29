// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IDiamondCut
/// @notice Interface for manage facet
interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice add/replace/remove facets
    /// @param _diamondCut array of changes
    /// @param _init addres for  initilization contractконтракта для инициализации
    /// @param _calldata data for call _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    /// @notice changes in facets
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}
