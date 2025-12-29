// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std-1.12.0/src/Script.sol";
import {console} from "forge-std-1.12.0/src/console.sol";
import {MockERC20} from "../test/mock/MockERC20.sol";

contract DeployMockERC20 is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        MockERC20 token = new MockERC20("Mock USDS", "mUSDS", 6);
        vm.stopBroadcast();

        console.log("MockERC20 deployed", address(token));

        return address(token);
    }
}
