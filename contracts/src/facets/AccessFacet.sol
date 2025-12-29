// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AppStorage, LibAppStorage} from "../libraries/LibAppStorage.sol";
import {IAccessFacet} from "../interfaces/IAccessFacet.sol";

contract AccessFacet is IAccessFacet {
    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyAdmin() {
        AppStorage storage s = LibAppStorage.appStorage();
        require(s.admin == msg.sender, "Not admin");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function isWhitelisted(address account) external view returns (bool) {
        return LibAppStorage.appStorage().whitelist[account];
    }

    function getAdmin() external view returns (address) {
        return LibAppStorage.appStorage().admin;
    }

    function getWhitelistedAddresses()
        external
        view
        returns (address[] memory)
    {
        return LibAppStorage.appStorage().whitelistedAddresses;
    }
    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function addToWhitelist(address account) external onlyAdmin {
        require(account != address(0), "Zero address");

        AppStorage storage s = LibAppStorage.appStorage();
        require(!s.whitelist[account], "Already in whitelist");

        s.whitelist[account] = true;
        s.whitelistIndex[account] = s.whitelistedAddresses.length;
        s.whitelistedAddresses.push(account);

        emit AddressAddedToWhitelist(account);
    }

    function removeFromWhitelist(address account) external onlyAdmin {
        require(account != address(0), "Zero address");
        AppStorage storage s = LibAppStorage.appStorage();
        require(s.whitelist[account], "Not whitelisted");

        ///  use "swap and pop" for remove el from array
        uint256 idx = s.whitelistIndex[account];
        uint256 lastIdx = s.whitelistedAddresses.length - 1;

        if (idx != lastIdx) {
            address lastAddress = s.whitelistedAddresses[lastIdx];
            s.whitelistedAddresses[idx] = lastAddress;
            s.whitelistIndex[lastAddress] = idx;
        }

        s.whitelistedAddresses.pop();
        delete s.whitelistIndex[account];
        s.whitelist[account] = false;

        emit AddressRemovedFromWhitelist(account);
    }
}
