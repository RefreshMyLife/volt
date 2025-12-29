// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std-1.12.0/src/Script.sol";
import {console} from "forge-std-1.12.0/src/console.sol";
import {AccessFacet} from "../src/facets/AccessFacet.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";

contract UpgradeAccessFacet is Script {
    address constant DIAMOND = 0x46b53ae6BDFbA4F96A52B027EC8e60760b74D6C7;

    function run() external {
        vm.startBroadcast();

        AccessFacet newAccessFacet = new AccessFacet();

        bytes4[] memory newSelectors = new bytes4[](1);
        newSelectors[0] = AccessFacet.getWhitelistedAddresses.selector;

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(newAccessFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: newSelectors
        });

        IDiamondCut(DIAMOND).diamondCut(cuts, address(0), "");

        vm.stopBroadcast();

        console.log("New AccessFacet:", address(newAccessFacet));
        console.log("Upgrade complete!");
    }
}
