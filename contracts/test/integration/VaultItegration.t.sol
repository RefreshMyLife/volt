// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std-1.12.0/src/Test.sol";
import {MockERC20} from "../../test/mock/MockERC20.sol";
import {DiamondHelper} from "../../test/helpers/DiamondHelper.sol";
import {IAccessFacet} from "../../src/interfaces/IAccessFacet.sol";
import {IVaultFacet} from "../../src/interfaces/IVaultFacet.sol";

/// @title VaultIntegrationTest
/// @notice Integration test for full life cycle  of Vault
contract VaultIntegrationTest is Test {
    MockERC20 public token;
    IAccessFacet public access;
    IVaultFacet public vault;

    address public owner = address(1);
    address public admin = address(2);
    address public user1 = address(3);
    address public user2 = address(4);
    address public user3 = address(5);

    uint256 constant INITIAL_BALANCE = 10_000 * 10 ** 6;
    uint256 constant DEPOSIT_AMOUNT = 1_000 * 10 ** 6;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(
        address indexed sender,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event AddressAddedToWhitelist(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);

    function setUp() public {
        token = new MockERC20("USD Stablecoin", "USDS", 6);
        DiamondHelper diamond = new DiamondHelper();

        address diamondAddr = diamond.deployDiamond(
            owner,
            address(token),
            admin
        );

        access = IAccessFacet(diamondAddr);
        vault = IVaultFacet(diamondAddr);

        token.mint(user1, INITIAL_BALANCE);
        token.mint(user2, INITIAL_BALANCE);
        token.mint(user3, INITIAL_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                          FULL USER LIFECYCLE
    //////////////////////////////////////////////////////////////*/

    function test_integration_fullUserLifecycle() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        assertTrue(access.isWhitelisted(user1), "User should be whitelisted");

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);

        vm.expectEmit(true, true, false, true);
        emit Deposit(user1, user1, DEPOSIT_AMOUNT, DEPOSIT_AMOUNT);

        uint256 shares = vault.deposit(DEPOSIT_AMOUNT, user1);
        vm.stopPrank();

        assertEq(
            shares,
            DEPOSIT_AMOUNT,
            "First deposit: shares should equal assets"
        );
        assertEq(
            vault.balanceOf(user1),
            DEPOSIT_AMOUNT,
            "User balance incorrect"
        );
        assertEq(vault.totalAssets(), DEPOSIT_AMOUNT, "Total assets incorrect");
        assertEq(
            token.balanceOf(address(vault)),
            DEPOSIT_AMOUNT,
            "Vault token balance incorrect"
        );
        assertEq(
            token.balanceOf(user1),
            INITIAL_BALANCE - DEPOSIT_AMOUNT,
            "User token balance incorrect"
        );

        vm.startPrank(user1);

        vm.expectEmit(true, true, true, true);
        emit Withdraw(user1, user1, user1, DEPOSIT_AMOUNT, DEPOSIT_AMOUNT);

        vault.withdraw(DEPOSIT_AMOUNT, user1, user1);
        vm.stopPrank();

        assertEq(vault.balanceOf(user1), 0, "User should have no shares");
        assertEq(vault.totalAssets(), 0, "Vault should be empty");
        assertEq(
            token.balanceOf(user1),
            INITIAL_BALANCE,
            "User should have all tokens back"
        );
        assertEq(
            token.balanceOf(address(vault)),
            0,
            "Vault should have no tokens"
        );
    }

    /*//////////////////////////////////////////////////////////////
                             MULTIPLE USERS
    //////////////////////////////////////////////////////////////*/

    function test_integration_multipleUsersInteraction() public {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        access.addToWhitelist(user3);
        vm.stopPrank();

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(1000 * 10 ** 6, user1);
        vm.stopPrank();

        uint256 user1Shares = vault.balanceOf(user1);
        assertEq(user1Shares, 1000 * 10 ** 6, "User1 shares incorrect");

        vm.startPrank(user2);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(2000 * 10 ** 6, user2);
        vm.stopPrank();

        uint256 user2Shares = vault.balanceOf(user2);
        assertEq(
            vault.totalAssets(),
            3000 * 10 ** 6,
            "Total assets should be 3000"
        );
        assertGt(user2Shares, user1Shares, "User2 should have more shares");

        vm.startPrank(user3);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(500 * 10 ** 6, user3);
        vm.stopPrank();

        assertEq(
            vault.totalAssets(),
            3500 * 10 ** 6,
            "Total assets should be 3500"
        );

        vm.prank(user1);
        vault.withdraw(500 * 10 ** 6, user1, user1);

        assertEq(
            vault.totalAssets(),
            3000 * 10 ** 6,
            "Total assets after withdrawal"
        );
        assertLt(
            vault.balanceOf(user1),
            user1Shares,
            "User1 shares should decrease"
        );

        assertEq(vault.balanceOf(user2), user2Shares, "User2 shares unchanged");
        assertGt(vault.balanceOf(user3), 0, "User3 still has shares");
    }

    /*//////////////////////////////////////////////////////////////
                    CONVERSION TO SHARES AND ASSETS
    //////////////////////////////////////////////////////////////*/

    function test_integration_shareConversionAccuracy() public {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        vm.stopPrank();

        // user1 first dep (1:1 ratio)
        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(1000 * 10 ** 6, user1);
        vm.stopPrank();

        assertEq(
            vault.convertToShares(1000 * 10 ** 6),
            1000 * 10 ** 6,
            "Initial conversion should be 1:1"
        );
        assertEq(
            vault.convertToAssets(1000 * 10 ** 6),
            1000 * 10 ** 6,
            "Initial reverse conversion should be 1:1"
        );

        vm.startPrank(user2);
        token.approve(address(vault), type(uint256).max);
        uint256 user2Shares = vault.deposit(1000 * 10 ** 6, user2);
        vm.stopPrank();

        // must be  1:1
        assertEq(
            user2Shares,
            1000 * 10 ** 6,
            "Equal deposits should give equal shares"
        );

        uint256 totalShares = vault.balanceOf(user1) + vault.balanceOf(user2);
        uint256 totalAssets = vault.totalAssets();

        assertEq(
            vault.convertToAssets(totalShares),
            totalAssets,
            "Total conversion should match"
        );
    }
    /*//////////////////////////////////////////////////////////////
                               WHITELIST
    //////////////////////////////////////////////////////////////*/

    function test_integration_whitelistDynamicChanges() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(1000 * 10 ** 6, user1);
        vm.stopPrank();

        uint256 user1Shares = vault.balanceOf(user1);
        assertGt(user1Shares, 0, "User1 should have shares");

        vm.prank(admin);
        access.removeFromWhitelist(user1);

        assertFalse(
            access.isWhitelisted(user1),
            "User1 should be removed from whitelist"
        );

        vm.startPrank(user1);
        vm.expectRevert("User not in whitelist");
        vault.deposit(100 * 10 ** 6, user1);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert("User not in whitelist");
        vault.withdraw(500 * 10 ** 6, user1, user1);
        vm.stopPrank();

        vm.prank(admin);
        access.addToWhitelist(user1);

        vm.prank(user1);
        vault.withdraw(500 * 10 ** 6, user1, user1);

        assertLt(
            vault.balanceOf(user1),
            user1Shares,
            "User1 shares decreased after withdrawal"
        );
    }

    function test_integration_unauthorizedAccessAttempts() public {
        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.expectRevert("User not in whitelist");
        vault.deposit(1000 * 10 ** 6, user1);
        vm.stopPrank();

        vm.prank(user2);
        vm.expectRevert("Not admin");
        access.addToWhitelist(user2);

        vm.prank(admin);
        access.addToWhitelist(user1);

        vm.startPrank(user1);
        vault.deposit(1000 * 10 ** 6, user1);
        vm.stopPrank();

        vm.prank(admin);
        access.addToWhitelist(user2);

        vm.prank(user2);
        vm.expectRevert("Not Owner");
        vault.withdraw(500 * 10 ** 6, user2, user1);
    }

    /*//////////////////////////////////////////////////////////////
                               EDGE CASES
    //////////////////////////////////////////////////////////////*/

    function test_integration_multipleSmallOperations() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);

        for (uint256 i = 0; i < 10; i++) {
            vault.deposit(100 * 10 ** 6, user1);
        }

        assertEq(
            vault.balanceOf(user1),
            1000 * 10 ** 6,
            "Total shares after multiple deposits"
        );
        assertEq(
            vault.totalAssets(),
            1000 * 10 ** 6,
            "Total assets after multiple deposits"
        );

        for (uint256 i = 0; i < 5; i++) {
            vault.withdraw(100 * 10 ** 6, user1, user1);
        }

        assertEq(
            vault.balanceOf(user1),
            500 * 10 ** 6,
            "Shares after partial withdrawals"
        );
        assertEq(
            vault.totalAssets(),
            500 * 10 ** 6,
            "Assets after partial withdrawals"
        );

        vm.stopPrank();
    }

    function test_integration_vaultEmptyAndRefill() public {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        vm.stopPrank();

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(1000 * 10 ** 6, user1);
        vault.withdraw(1000 * 10 ** 6, user1, user1);
        vm.stopPrank();

        assertEq(vault.totalAssets(), 0, "Vault should be empty");
        assertEq(vault.balanceOf(user1), 0, "User1 should have no shares");

        vm.startPrank(user2);
        token.approve(address(vault), type(uint256).max);
        uint256 shares = vault.deposit(2000 * 10 ** 6, user2);
        vm.stopPrank();

        assertEq(
            shares,
            2000 * 10 ** 6,
            "First deposit after empty should be 1:1"
        );
        assertEq(vault.totalAssets(), 2000 * 10 ** 6, "New total assets");
    }

    function test_integration_depositToAnotherAddress() public {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        vm.stopPrank();

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(1000 * 10 ** 6, user2);
        vm.stopPrank();

        assertEq(vault.balanceOf(user1), 0, "User1 should have no shares");
        assertEq(
            vault.balanceOf(user2),
            1000 * 10 ** 6,
            "User2 should have shares"
        );
        assertEq(
            token.balanceOf(user1),
            INITIAL_BALANCE - 1000 * 10 ** 6,
            "User1 paid tokens"
        );

        vm.prank(user2);
        vault.withdraw(1000 * 10 ** 6, user2, user2);

        assertEq(
            token.balanceOf(user2),
            INITIAL_BALANCE + 1000 * 10 ** 6,
            "User2 received tokens"
        );
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function test_integration_bulkWhitelistOperations() public {
        address[] memory users = new address[](3);
        users[0] = user1;
        users[1] = user2;
        users[2] = user3;

        vm.startPrank(admin);
        for (uint256 i = 0; i < users.length; i++) {
            access.addToWhitelist(users[i]);
        }
        vm.stopPrank();

        address[] memory whitelisted = access.getWhitelistedAddresses();
        assertEq(whitelisted.length, 4, "Should have admin + 3 users");

        for (uint256 i = 0; i < users.length; i++) {
            assertTrue(
                access.isWhitelisted(users[i]),
                "User should be whitelisted"
            );
        }

        vm.startPrank(admin);
        for (uint256 i = 0; i < users.length; i++) {
            access.removeFromWhitelist(users[i]);
        }
        vm.stopPrank();

        whitelisted = access.getWhitelistedAddresses();
        assertEq(whitelisted.length, 1, "Should have only admin");

        for (uint256 i = 0; i < users.length; i++) {
            assertFalse(
                access.isWhitelisted(users[i]),
                "User should be removed"
            );
        }
    }

    function test_integration_adminSelfRemoval() public {
        assertTrue(
            access.isWhitelisted(admin),
            "Admin should be whitelisted by default"
        );

        vm.prank(admin);
        access.removeFromWhitelist(admin);

        assertFalse(
            access.isWhitelisted(admin),
            "Admin removed from whitelist"
        );

        vm.prank(admin);
        access.addToWhitelist(user1);

        assertTrue(access.isWhitelisted(user1), "Admin can still add users");

        token.mint(admin, 1000 * 10 ** 6);

        vm.startPrank(admin);
        token.approve(address(vault), type(uint256).max);
        vm.expectRevert("User not in whitelist");
        vault.deposit(100 * 10 ** 6, admin);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                              STRESS TESTS
    //////////////////////////////////////////////////////////////*/

    function test_integration_stressTestManyOperations() public {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        vm.stopPrank();

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user2);
        token.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        uint256 iterations = 20;

        for (uint256 i = 0; i < iterations; i++) {
            vm.prank(user1);
            vault.deposit(50 * 10 ** 6, user1);

            vm.prank(user2);
            vault.deposit(50 * 10 ** 6, user2);
        }

        uint256 expectedTotal = iterations * 2 * 50 * 10 ** 6;
        assertEq(
            vault.totalAssets(),
            expectedTotal,
            "Total assets after many deposits"
        );

        for (uint256 i = 0; i < iterations / 2; i++) {
            vm.prank(user1);
            vault.withdraw(50 * 10 ** 6, user1, user1);

            vm.prank(user2);
            vault.withdraw(50 * 10 ** 6, user2, user2);
        }

        uint256 expectedAfterWithdrawals = expectedTotal -
            (iterations * 50 * 10 ** 6);
        assertEq(
            vault.totalAssets(),
            expectedAfterWithdrawals,
            "Total assets after withdrawals"
        );
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function test_integration_viewFunctionsConsistency() public {
        vm.startPrank(admin);
        access.addToWhitelist(user1);
        access.addToWhitelist(user2);
        vm.stopPrank();

        assertEq(vault.asset(), address(token), "Asset address");
        assertEq(vault.totalAssets(), 0, "Initial total assets");
        assertEq(access.getAdmin(), admin, "Admin address");

        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(1000 * 10 ** 6, user1);
        vm.stopPrank();

        vm.startPrank(user2);
        token.approve(address(vault), type(uint256).max);
        vault.deposit(500 * 10 ** 6, user2);
        vm.stopPrank();

        // check consistency
        uint256 user1Balance = vault.balanceOf(user1);
        uint256 user2Balance = vault.balanceOf(user2);
        uint256 totalAssets = vault.totalAssets();

        assertEq(
            totalAssets,
            1500 * 10 ** 6,
            "Total assets should match deposits"
        );

        uint256 user1Assets = vault.convertToAssets(user1Balance);
        uint256 user2Assets = vault.convertToAssets(user2Balance);

        assertEq(
            user1Assets + user2Assets,
            totalAssets,
            "Sum of user assets should equal total"
        );

        address[] memory whitelisted = access.getWhitelistedAddresses();
        assertEq(whitelisted.length, 3, "Should have admin + 2 users");
    }
}
