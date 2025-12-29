// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";
import {IVaultFacet} from "../interfaces/IVaultFacet.sol";
import {IERC20} from "@openzeppelin-contracts-5.3.0/interfaces/IERC20.sol";
import {
    SafeERC20
} from "@openzeppelin-contracts-5.3.0/token/ERC20/utils/SafeERC20.sol";
contract VaultFacet is IVaultFacet {
    using SafeERC20 for IERC20;
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
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

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyWhitelisted() {
        require(
            LibAppStorage.appStorage().whitelist[msg.sender],
            "User not in whitelist"
        );
        _;
    }
    modifier nonReentrant() {
        AppStorage storage s = LibAppStorage.appStorage();
        require(s.status != ENTERED, "Reentrant call");
        s.status = ENTERED;
        _;

        s.status = NOT_ENTERED;
    }
    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function asset() external view returns (address) {
        return LibAppStorage.appStorage().tokenAssetAddress;
    }

    function totalAssets() external view returns (uint256) {
        return LibAppStorage.appStorage().totalAssets;
    }

    function balanceOf(address account) external view returns (uint256) {
        return LibAppStorage.appStorage().shares[account];
    }

    function convertToShares(uint256 assets) public view returns (uint256) {
        AppStorage storage s = LibAppStorage.appStorage();
        // when first dep, then assets == shares
        if (s.totalAssets == 0) {
            return assets;
        }
        return ((assets * s.totalShares) / s.totalAssets);
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        AppStorage storage s = LibAppStorage.appStorage();
        // when first dep, then assets == shares
        if (s.totalShares == 0) {
            return shares;
        }
        return ((shares * s.totalAssets) / s.totalShares);
    }

    /*//////////////////////////////////////////////////////////////
                            USER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function deposit(
        uint256 assets,
        address receiver
    ) external onlyWhitelisted nonReentrant returns (uint256 shares) {
        require(assets > 0, "Not have assets");
        require(receiver != address(0), "Receiver address is zero");

        AppStorage storage s = LibAppStorage.appStorage();
        shares = convertToShares(assets);
        s.totalAssets += assets;
        s.totalShares += shares;
        s.shares[receiver] += shares;

        IERC20(s.tokenAssetAddress).safeTransferFrom(
            msg.sender,
            address(this),
            assets
        );

        emit Deposit(msg.sender, receiver, assets, shares);
        return shares;
    }

    function withdraw(
        uint256 shares,
        address receiver,
        address owner
    ) external onlyWhitelisted nonReentrant returns (uint256 assets) {
        require(msg.sender == owner, "Not Owner");
        require(shares > 0, "Not have shares");
        require(receiver != address(0), "Receiver address is zero");
        AppStorage storage s = LibAppStorage.appStorage();
        assets = convertToAssets(shares);
        require(s.shares[owner] >= shares, "Not have shares");

        s.totalShares -= shares;
        s.totalAssets -= assets;
        s.shares[owner] -= shares;

        IERC20(s.tokenAssetAddress).safeTransfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        return assets;
    }
}
