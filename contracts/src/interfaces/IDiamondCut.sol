// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IDiamondCut
/// @notice Интерфейс для добавления/удаления/замены facets
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

    /// @notice Добавить/заменить/удалить facets
    /// @param _diamondCut Массив изменений
    /// @param _init Адрес контракта для инициализации
    /// @param _calldata Данные для вызова _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    /// @notice изменениe facets
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}
