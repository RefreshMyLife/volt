// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IDiamondLoupe
/// @notice Интерфейс для просмотра facets
interface IDiamondLoupe {
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Получить все facets и их функции
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Получить все функции facet
    function facetFunctionSelectors(
        address _facet
    ) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Получить все адреса facets
    function facetAddresses()
        external
        view
        returns (address[] memory facetAddresses_);

    /// @notice Найти facet по селектору функции
    function facetAddress(
        bytes4 _functionSelector
    ) external view returns (address facetAddress_);
}
