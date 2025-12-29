// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std-1.12.0/src/Test.sol";
import {MockERC20} from "../mock/MockERC20.sol";
import {DiamondHelper} from "../helpers/DiamondHelper.sol";
import {IVaultFacet} from "../../src/interfaces/IVaultFacet.sol";
import {IAccessFacet} from "../../src/interfaces/IAccessFacet.sol";

contract VaultFacetTest is Test {
    MockERC20 public token;

    address public admin = address(2);
    address public user1 = address(3);
    address public user2 = address(4);

    IAccessFacet public access;
    IVaultFacet public vault;

    function setUp() public {
        token = new MockERC20("USD coin", "USDS", 6);
        DiamondHelper diamond = new DiamondHelper();

        address diamondAddr = diamond.deployDiamond(
            msg.sender,
            address(token),
            admin
        );

        vault = IVaultFacet(diamondAddr);
        access = IAccessFacet(diamondAddr);
    }

    /*//////////////////////////////////////////////////////////////
                             DEPOSIT  TEST
    //////////////////////////////////////////////////////////////*/

    function test_deposit_revertsWhenAmountIsZero() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        token.mint(user1, 1000 * 10 ** 6);

        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);

        vm.expectRevert("Not have assets");
        vm.prank(user1);
        vault.deposit(0, user1);
    }

    function test_deposit_successfulFirstDeposit() public {
        // Arrange
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);

        // Act
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        // Assert
        assertEq(
            token.balanceOf(address(vault)),
            100 * 10 ** 6,
            "Vault should receive tokens"
        );
        assertEq(
            token.balanceOf(user1),
            900 * 10 ** 6,
            "User should have remaining tokens"
        );
        assertEq(
            vault.balanceOf(user1),
            100 * 10 ** 6,
            "User should have correct shares"
        );
        assertEq(
            vault.totalAssets(),
            100 * 10 ** 6,
            "Vault should have correct total assets"
        );
    }

    function test_deposit_revertsWhenNotWhitelisted() public {
        token.mint(user1, 1000 * 10 ** 6);

        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);

        vm.expectRevert("User not in whitelist");
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);
    }

    function test_deposit_revertsWhenReceiverAddressIsZero() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        token.mint(user1, 1000 * 10 ** 6);

        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);

        vm.expectRevert("Receiver address is zero");
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, address(0));
    }

    function test_deposit_multipleDepositsFromSameUser() public {
        // Arrange
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);

        // First deposit
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);
        uint256 sharesAfterFirst = vault.balanceOf(user1);

        // Second deposit
        vm.prank(user1);
        vault.deposit(200 * 10 ** 6, user1);

        // Assert
        assertEq(
            token.balanceOf(address(vault)),
            vault.totalAssets(),
            "Vault should have total deposits"
        );
        assertEq(
            token.balanceOf(user1),
            700 * 10 ** 6,
            "User should have remaining tokens"
        );
        assertGt(
            vault.balanceOf(user1),
            sharesAfterFirst,
            "User should have more shares"
        );
        assertEq(
            vault.totalAssets(),
            300 * 10 ** 6,
            "Total assets should match deposits"
        );
    }

    function test_deposit_multipleUsersDeposit() public {
        // Arrange
        vm.prank(admin);
        access.addToWhitelist(user1);
        vm.prank(admin);
        access.addToWhitelist(user2);

        token.mint(user1, 1000 * 10 ** 6);
        token.mint(user2, 2000 * 10 ** 6);

        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user2);
        token.approve(address(vault), type(uint256).max);

        // Act
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        vm.prank(user2);
        vault.deposit(200 * 10 ** 6, user2);

        // Assert
        assertEq(
            vault.totalAssets(),
            300 * 10 ** 6,
            "Total assets should be sum of deposits"
        );
        assertGt(vault.balanceOf(user1), 0, "User1 should have shares");
        assertGt(vault.balanceOf(user2), 0, "User2 should have shares");
        assertEq(
            token.balanceOf(address(vault)),
            300 * 10 ** 6,
            "Vault should hold all tokens"
        );
    }

    function test_deposit_revertsWithInsufficientBalance() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        token.mint(user1, 50 * 10 ** 6); // Mint only 50

        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);

        vm.expectRevert(); // SafeERC20 will revert
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);
    }

    function test_deposit_revertsWithInsufficientApproval() public {
        vm.prank(admin);
        access.addToWhitelist(user1);

        token.mint(user1, 1000 * 10 ** 6);

        vm.prank(user1);
        token.approve(address(vault), 50 * 10 ** 6); // Approve only 50

        vm.expectRevert(); // SafeERC20 will revert
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);
    }

    /*//////////////////////////////////////////////////////////////
                             WITHDRAW TEST
    //////////////////////////////////////////////////////////////*/

    function test_withdraw_successfulWithdraw() public {
        // Setup: user1 deposits first
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        uint256 userSharesBefore = vault.balanceOf(user1);
        uint256 userTokensBefore = token.balanceOf(user1);

        // Act: withdraw 50 tokens
        vm.prank(user1);
        vault.withdraw(50 * 10 ** 6, user1, user1);

        // Assert
        assertEq(
            token.balanceOf(user1),
            userTokensBefore + 50 * 10 ** 6,
            "User should receive tokens"
        );
        assertEq(
            token.balanceOf(address(vault)),
            50 * 10 ** 6,
            "Vault should have remaining tokens"
        );
        assertLt(
            vault.balanceOf(user1),
            userSharesBefore,
            "User shares should decrease"
        );
        assertEq(
            vault.totalAssets(),
            50 * 10 ** 6,
            "Total assets should decrease"
        );
    }

    function test_withdraw_revertsWhenAmountIsZero() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        vm.expectRevert("Not have assets");
        vm.prank(user1);
        vault.withdraw(0, user1, user1);
    }

    function test_withdraw_revertsWhenNotOwner() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        vm.prank(admin);
        access.addToWhitelist(user2);

        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        vm.expectRevert("Not Owner");
        vm.prank(user2); // user2 tries to withdraw user1's funds
        vault.withdraw(50 * 10 ** 6, user2, user1);
    }

    function test_withdraw_revertsWhenInsufficientShares() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        vm.expectRevert("Not have shares");
        vm.prank(user1);
        vault.withdraw(200 * 10 ** 6, user1, user1); // Try to withdraw more than deposited
    }

    function test_withdraw_revertsWhenNotWhitelisted() public {
        // First deposit while whitelisted
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        // Remove from whitelist
        vm.prank(admin);
        access.removeFromWhitelist(user1);

        // Try to withdraw
        vm.expectRevert("User not in whitelist");
        vm.prank(user1);
        vault.withdraw(50 * 10 ** 6, user1, user1);
    }

    function test_withdraw_fullWithdraw() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        // Withdraw everything
        vm.prank(user1);
        vault.withdraw(100 * 10 ** 6, user1, user1);

        // Assert
        assertEq(
            token.balanceOf(user1),
            1000 * 10 ** 6,
            "User should have all tokens back"
        );
        assertEq(token.balanceOf(address(vault)), 0, "Vault should be empty");
        assertEq(vault.balanceOf(user1), 0, "User should have no shares");
        assertEq(vault.totalAssets(), 0, "Total assets should be zero");
    }

    function test_withdraw_revertsWhenReceiverAddressIsZero() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        vm.expectRevert("Receiver address is zero");
        vm.prank(user1);
        vault.withdraw(50 * 10 ** 6, address(0), user1);
    }

    /*//////////////////////////////////////////////////////////////
                            CONVERSION TEST
    //////////////////////////////////////////////////////////////*/

    function test_convertToShares_firstDepositReturnsEqualShares() public view {
        uint256 assets = 100 * 10 ** 6;
        uint256 shares = vault.convertToShares(assets);

        assertEq(shares, assets, "First deposit should return 1:1 shares");
    }

    function test_convertToShares_afterDepositReturnsCorrectRatio() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        uint256 assets = 50 * 10 ** 6;
        uint256 shares = vault.convertToShares(assets);

        assertEq(shares, 50 * 10 ** 6, "Should maintain 1:1 ratio");
    }

    function test_convertToAssets_correctConversion() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        uint256 userShares = vault.balanceOf(user1);
        uint256 assets = vault.convertToAssets(userShares);

        assertEq(
            assets,
            100 * 10 ** 6,
            "Should convert back to original assets"
        );
    }

    function test_convertToAssets_whenVaultEmpty() public view {
        // Vault is empty (totalShares == 0)
        uint256 shares = 100 * 10 ** 6;
        uint256 assets = vault.convertToAssets(shares);

        // first dep => assets == shares (1:1)
        assertEq(assets, shares, "Should return 1:1 ratio when vault is empty");
    }

    /*//////////////////////////////////////////////////////////////
                               ASSET TEST
    //////////////////////////////////////////////////////////////*/

    function test_asset_returnsCorrectToken() public view {
        address assetAddress = vault.asset();
        assertEq(
            assetAddress,
            address(token),
            "Asset should be the token address"
        );
    }

    function test_totalAssets_tracksCorrectly() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        vm.prank(admin);
        access.addToWhitelist(user2);

        token.mint(user1, 1000 * 10 ** 6);
        token.mint(user2, 1000 * 10 ** 6);

        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);
        vm.prank(user2);
        token.approve(address(vault), type(uint256).max);

        assertEq(vault.totalAssets(), 0, "Initially should be zero");

        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);
        assertEq(
            vault.totalAssets(),
            100 * 10 ** 6,
            "Should track first deposit"
        );

        vm.prank(user2);
        vault.deposit(200 * 10 ** 6, user2);
        assertEq(
            vault.totalAssets(),
            300 * 10 ** 6,
            "Should track multiple deposits"
        );

        vm.prank(user1);
        vault.withdraw(50 * 10 ** 6, user1, user1);
        assertEq(
            vault.totalAssets(),
            250 * 10 ** 6,
            "Should track withdrawals"
        );
    }

    function test_balanceOf_tracksUserShares() public {
        vm.prank(admin);
        access.addToWhitelist(user1);
        token.mint(user1, 1000 * 10 ** 6);
        vm.prank(user1);
        token.approve(address(vault), type(uint256).max);

        assertEq(vault.balanceOf(user1), 0, "Initial balance should be zero");

        vm.prank(user1);
        vault.deposit(100 * 10 ** 6, user1);

        assertEq(
            vault.balanceOf(user1),
            100 * 10 ** 6,
            "Balance should reflect shares"
        );
    }
}
