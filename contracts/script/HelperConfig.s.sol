// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std-1.12.0/src/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address admin;
        address tokenAssetAddress;
    }

    function getSepoliaConfig() internal pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                tokenAssetAddress: 0x131B1Bc732eCE6ae89E208e5E314ac437e118248,
                admin: 0xBdE330368d3E078bF8802797A116a66F1082a996
            });
    }

    function getAnvilConfig() internal pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                tokenAssetAddress: 0x131B1Bc732eCE6ae89E208e5E314ac437e118248,
                admin: 0xBdE330368d3E078bF8802797A116a66F1082a996
            });
    }

    function getConfig() public returns (NetworkConfig memory) {
        if (block.chainid == 11155111) {
            return getSepoliaConfig();
        } else {
            return getAnvilConfig();
        }
    }
}
