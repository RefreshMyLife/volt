// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std-1.12.0/src/Test.sol";
import {MockERC20} from "../mock/MockERC20.sol";
import {DiamondHelper} from "../helpers/DiamondHelper.sol";
import {IAccessFacet} from "../../src/interfaces/IAccessFacet.sol";

contract AccessFacetTest is Test {
    MockERC20 public token;

    address public admin = address(2);
    address public user1 = address(3);
    address public user2 = address(4);

    IAccessFacet public access;
    function setUp() public {
        token = new MockERC20("USD coin", "USDS", 6);
        DiamondHelper diamond = new DiamondHelper();

        address diamondAddr = diamond.deployDiamond(
            msg.sender,
            address(token),
            admin
        );

        access = IAccessFacet(diamondAddr);
    }

    function test_getAdmin_returnsCorrectAdmin() public {
        assertEq(access.getAdmin(), admin, "Admin must be correct ");
    }

    function test_isWhitelisted_adminIsWhitelisted() public {
        assertTrue(
            access.isWhitelisted(admin),
            "Admin must be in whitelist by default"
        );
    }

    function test_addToWhitelist_userAddedToWhitelist() public {
        assertFalse(access.isWhitelisted(user1), "User in whitelist");

        vm.prank(admin);
        access.addToWhitelist(user1);

        assertTrue(access.isWhitelisted(user1));
    }

    function test_removeFromWhitelist_userRemoveFromWhitelist() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        assertTrue(access.isWhitelisted(user1), "User should be in whitelist");

        vm.prank(admin);
        access.removeFromWhitelist(user1);

        assertFalse(access.isWhitelisted(user1), "User should be removed");
    }
}
