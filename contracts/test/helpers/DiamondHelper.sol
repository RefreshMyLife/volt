// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std-1.12.0/src/Test.sol";
import {Diamond} from "../../src/diamond/Diamond.sol";
import {DiamondCutFacet} from "../../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/facets/DiamondLoupeFacet.sol";
import {AccessFacet} from "../../src/facets/AccessFacet.sol";
import {VaultFacet} from "../../src/facets/VaultFacet.sol";
import {DiamondInit} from "../../src/upgradeInitializers/DiamondInit.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";

/// @notice Helper для деплоя Diamond в тестах
contract DiamondHelper is Test {
    Diamond public diamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    AccessFacet public accessFacet;
    VaultFacet public vaultFacet;
    DiamondInit public diamondInit;

    /// @notice деплой всех контрактов и facet
    /// @param _owner адрес владельца
    /// @param _asset адрес токена-вклада (USDS)
    /// @param _admin адрес админа
    function deployDiamond(
        address _owner,
        address _asset,
        address _admin
    ) public returns (address) {
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        accessFacet = new AccessFacet();
        vaultFacet = new VaultFacet();
        diamondInit = new DiamondInit();

        diamond = new Diamond(_owner, address(diamondCutFacet));

        // сollect selectors for DiamondLoupeFacet
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = DiamondLoupeFacet.facets.selector;
        loupeSelectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        loupeSelectors[2] = DiamondLoupeFacet.facetAddress.selector;
        loupeSelectors[3] = DiamondLoupeFacet.facetAddresses.selector;

        // сollect selectors for AccessFacet
        bytes4[] memory accessSelectors = new bytes4[](5);
        accessSelectors[0] = AccessFacet.isWhitelisted.selector;
        accessSelectors[1] = AccessFacet.getAdmin.selector;
        accessSelectors[2] = AccessFacet.addToWhitelist.selector;
        accessSelectors[3] = AccessFacet.removeFromWhitelist.selector;
        accessSelectors[4] = AccessFacet.getWhitelistedAddresses.selector;

        // сollect selectors for VaultFacet
        bytes4[] memory vaultSelectors = new bytes4[](7);
        vaultSelectors[0] = VaultFacet.asset.selector;
        vaultSelectors[1] = VaultFacet.totalAssets.selector;
        vaultSelectors[2] = VaultFacet.balanceOf.selector;
        vaultSelectors[3] = VaultFacet.convertToShares.selector;
        vaultSelectors[4] = VaultFacet.convertToAssets.selector;
        vaultSelectors[5] = VaultFacet.deposit.selector;
        vaultSelectors[6] = VaultFacet.withdraw.selector;

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);

        /// @notice Добавляем селекторы в facet
        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        cuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(accessFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: accessSelectors
        });
        cuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(vaultFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: vaultSelectors
        });

        /// @notice готовим данные
        bytes memory initCalldata = abi.encodeWithSelector(
            DiamondInit.init.selector,
            _asset,
            _admin
        );

        vm.prank(_owner);
        IDiamondCut(address(diamond)).diamondCut(
            cuts,
            address(diamondInit),
            initCalldata
        );

        return address(diamond);
    }
}
