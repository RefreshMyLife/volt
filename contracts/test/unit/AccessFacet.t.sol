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

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event AddressAddedToWhitelist(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);

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

    /// @notice helper function that added users to whitelist
    function _addUsersToWhitelist() internal {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        vm.stopPrank();
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
    /*//////////////////////////////////////////////////////////////
                         ADD TO WHITELIST TEST
    //////////////////////////////////////////////////////////////*/
    function test_addToWhitelist_userAddedToWhitelist() public {
        assertFalse(access.isWhitelisted(user1), "User in whitelist");

        vm.prank(admin);
        access.addToWhitelist(user1);

        assertTrue(access.isWhitelisted(user1));
    }

    function test_addToWhitelist_revertsWhenCallerIsNotAdmin() public {
        vm.prank(user1);
        vm.expectRevert("Not admin");
        access.addToWhitelist(user1);
    }
    function test_addToWhitelist_revertsWhenAddressIsZero() public {
        vm.prank(admin);
        vm.expectRevert("Zero address");
        access.addToWhitelist(address(0));
    }

    function test_addToWhitelist_revertsWhenAddSameAddress() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        vm.prank(admin);
        vm.expectRevert("Already in whitelist");
        access.addToWhitelist(user1);
    }
    function test_addToWhitelist_emitsEvent() public {
        vm.expectEmit(true, false, false, false);
        emit AddressAddedToWhitelist(user1);

        vm.prank(admin);
        access.addToWhitelist(user1);
    }

    function test_addToWhitelist_revertsWhenAddingAdminAgain() public {
        vm.prank(admin);
        vm.expectRevert("Already in whitelist");
        access.addToWhitelist(admin);
    }
    /*//////////////////////////////////////////////////////////////
                       REMOVE FROM WHITELIST TEST
    //////////////////////////////////////////////////////////////*/
    function test_removeFromWhitelist_userRemoveFromWhitelist() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        assertTrue(access.isWhitelisted(user1), "User should be in whitelist");

        vm.prank(admin);
        access.removeFromWhitelist(user1);

        assertFalse(access.isWhitelisted(user1), "User should be removed");
    }

    function test_removeFromWhitelist_userRemoveFromMiddleWhitelist() public {
        _addUsersToWhitelist();
        vm.prank(admin);
        access.removeFromWhitelist(user1);

        address[] memory whitelist = access.getWhitelistedAddresses();
        assertFalse(access.isWhitelisted(user1), "User should be removed");
        assertEq(whitelist.length, 2, "Whitelist must contain admin and user2");
        assertEq(whitelist[0], admin, "First element must be admin");
        assertEq(whitelist[1], user2, "Second element must be user2");
    }

    function test_removeFromWhitelist_revertWhenAddressIsZero() public {
        vm.prank(admin);
        vm.expectRevert("Zero address");
        access.removeFromWhitelist(address(0));
    }

    function test_removeFromWhitelist_revertsWhenAddressIsNotInWhitelist()
        public
    {
        vm.prank(admin);
        vm.expectRevert("Not whitelisted");
        access.removeFromWhitelist(user1);
    }
    function test_removeFromWhitelist_emitsEvent() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        vm.expectEmit(true, false, false, false);
        emit AddressRemovedFromWhitelist(user1);

        vm.prank(admin);
        access.removeFromWhitelist(user1);
    }

    function test_removeFromWhitelist_adminCanRemoveHimself() public {
        vm.prank(admin);
        access.removeFromWhitelist(admin);

        assertFalse(access.isWhitelisted(admin));
    }
    function test_removeFromWhitelist_revertsWhenCallerIsNotAdmin() public {
        vm.prank(admin);
        access.addToWhitelist(user2);

        vm.prank(user1);
        vm.expectRevert("Not admin");
        access.removeFromWhitelist(user2);
    }
    /*//////////////////////////////////////////////////////////////
                     GET WHITELISTED ADDRESSES TEST
    //////////////////////////////////////////////////////////////*/
    function test_getWhitelistedAddresses_returnArrayAddress() public {
        _addUsersToWhitelist();

        address[] memory whitelistArrayAddr = access.getWhitelistedAddresses();

        assertEq(
            whitelistArrayAddr.length,
            3,
            "Should have correct number of addresses (admin, user1, user2)"
        );

        assertEq(whitelistArrayAddr[0], admin, "First element must be admin");
        assertEq(whitelistArrayAddr[1], user1, "Second element must be user1");
        assertEq(whitelistArrayAddr[2], user2, "Third element must be user2");
    }

    function test_getWhitelistedAddresses_afterRemoval() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        vm.prank(admin);
        access.removeFromWhitelist(user1);

        address[] memory list = access.getWhitelistedAddresses();
        assertEq(list.length, 1, "Array must be contain only admin address");
        assertEq(list[0], admin, "Remaining address should be admin");
    }

    function test_getWhitelistedAddresses_afterRemovalLastElement() public {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        access.removeFromWhitelist(user2);
        vm.stopPrank();

        address[] memory list = access.getWhitelistedAddresses();
        assertEq(list.length, 2, "Should have 2 addresses");
        assertEq(list[0], admin, "First should be admin");
        assertEq(list[1], user1, "Second should be user1");
    }
}
