// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ISaleConditions} from "../src/interfaces/ISaleConditions.sol";
import "../src/libraries/ListingLib.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockAssetListing} from "./mock/MockAssetListing.sol";

contract MockAssetListingTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AssetListed(AssetNft indexed asset, ListingLib.Status indexed status);

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    AssetNft public nftAsset;
    MockMarketplace public marketplace;
    MockAssetListing public listing;
    address immutable owner = msg.sender;

    function setUp() public {
        nftAsset = new AssetNft("AssetMocked", "MA1", owner);
        marketplace = new MockMarketplace();
        listing = new MockAssetListing();

        vm.prank(owner);
        nftAsset.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );
    }

    function testOnlyOwnerCanListAsset() external {
        // Verify revert
        vm.expectRevert("NOT_OWNER");
        listing.listAsset(nftAsset);
        // verify success after prank
        vm.prank(owner);
        listing.listAsset(nftAsset);
    }

    function testEventEmittanceAssetListed() external {
        vm.startPrank(owner);

        vm.expectEmit(true, true, true, true);
        emit AssetListed(nftAsset, ListingLib.Status.ActiveListing);
        listing.listAsset(nftAsset);
    }

    function testListingStatusOnceAssetListed() external {
        vm.startPrank(owner);

        listing.listAsset(nftAsset);

        // Get saved listing and compare with values passed above
        uint256 savedStatus = uint256(listing.listingStatusOf(nftAsset));
        uint256 expectedStatus = uint256(ListingLib.Status.ActiveListing);

        assertEq(savedStatus, expectedStatus);
    }
}
