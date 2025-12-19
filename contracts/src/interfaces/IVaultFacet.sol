// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import {IERC4626} from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";

/// @title IVaultFacet
/// @notice Интерфейс для работы с хранилищем (deposit, withdraw...)
interface IVaultFacet {
    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTION
    //////////////////////////////////////////////////////////////*/

    ///@notice Перевод долей в токены
    function convertToAssets(
        uint256 sharesS
    ) external view returns (uint256 assets);

    /// @notice перевод вклада в доли
    function convertToShares(
        uint256 assets
    ) external view returns (uint256 shares);

    /// @notice всего вкладов (TVL)
    function totalAssets() external view returns (uint256);
    /*//////////////////////////////////////////////////////////////
                             USER FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @notice Депозит токенов в Vault(хранилище)
    /// @return shares количество токенов (долей)
    function deposit(
        uint256 assets,
        address receiver
    ) external returns (uint256 shares);

    /// @notice  Вывод токенов из Vault
    /// @return shares количество токенов который должны быть сожжены
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);
}
