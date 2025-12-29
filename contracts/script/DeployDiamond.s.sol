// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std-1.12.0/src/Script.sol";
import {console} from "forge-std-1.12.0/src/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Diamond} from "../src/diamond/Diamond.sol";
import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../src/facets/DiamondLoupeFacet.sol";
import {AccessFacet} from "../src/facets/AccessFacet.sol";
import {VaultFacet} from "../src/facets/VaultFacet.sol";
import {DiamondInit} from "../src/upgradeInitializers/DiamondInit.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";

contract DeployDiamond is Script {
    Diamond public diamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    AccessFacet public accessFacet;
    VaultFacet public vaultFacet;
    DiamondInit public diamondInit;
    function run() external returns (address) {
        HelperConfig config = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = config.getConfig();
        vm.startBroadcast();

        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        accessFacet = new AccessFacet();
        vaultFacet = new VaultFacet();
        diamondInit = new DiamondInit();
        diamond = new Diamond(msg.sender, address(diamondCutFacet));

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

        // define the cut for DiamondLoupeFacet
        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });
        // define the cut for AccessFacet
        cuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(accessFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: accessSelectors
        });
        // define the cut for VaultFacet
        cuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(vaultFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: vaultSelectors
        });

        // prepare init data
        bytes memory initCalldata = abi.encodeWithSelector(
            DiamondInit.init.selector,
            networkConfig.tokenAssetAddress,
            networkConfig.admin
        );

        // execute the cut to add facets and initialize state
        IDiamondCut(address(diamond)).diamondCut(
            cuts,
            address(diamondInit),
            initCalldata
        );
        vm.stopBroadcast();
        console.log("=== Deployed Contracts ===");
        console.log("Diamond:", address(diamond));
        console.log("DiamondCutFacet:", address(diamondCutFacet));
        return address(diamond);
    }
}
