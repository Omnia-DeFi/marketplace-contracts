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
    event AssetListed(
        AssetNft indexed asset,
        ISaleConditions.Conditions indexed conditions,
        ISaleConditions.ExtraSaleTerms indexed extras,
        ListingLib.Status status
    );

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    AssetNft public nftAsset;
    MockMarketplace public marketplace;
    MockAssetListing public listing;
    address immutable owner = msg.sender;

    function returnCreatedSaleConditions()
        public
        returns (
            ISaleConditions.Conditions memory conditions,
            ISaleConditions.ExtraSaleTerms memory extras
        )
    {
        conditions.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        conditions.paymentTerms.consummationSaleTimeframe = 24 hours;

        extras.label = "RandomLabel";
        extras.customTermDescription = "short";
    }

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
        (
            ISaleConditions.Conditions memory conditions_,
            ISaleConditions.ExtraSaleTerms memory extras_
        ) = returnCreatedSaleConditions();

        // Verify revert
        vm.expectRevert("NOT_OWNER");
        listing.listAsset(nftAsset, conditions_, extras_);
        // verify success after prank
        vm.prank(owner);
        listing.listAsset(nftAsset, conditions_, extras_);
    }

    function testEventEmittanceAssetListed() external {
        vm.startPrank(owner);

        (
            ISaleConditions.Conditions memory conditions_,
            ISaleConditions.ExtraSaleTerms memory extras_
        ) = returnCreatedSaleConditions();

        vm.expectEmit(true, true, true, true);
        emit AssetListed(
            nftAsset,
            conditions_,
            extras_,
            ListingLib.Status.ActiveListing
        );
        listing.listAsset(nftAsset, conditions_, extras_);
    }

    function testVerifyListingSavingValues() external {
        vm.startPrank(owner);

        (
            ISaleConditions.Conditions memory conditions_,
            ISaleConditions.ExtraSaleTerms memory extras_
        ) = returnCreatedSaleConditions();

        listing.listAsset(nftAsset, conditions_, extras_);

        // Get saved listing and compare with values passed above
        (
            ISaleConditions.Conditions memory savedConditions,
            ISaleConditions.ExtraSaleTerms memory savedExtras,
            ListingLib.Status savedStatus
        ) = listing.listingOf(nftAsset);

        // fllor price
        assertEq(savedConditions.floorPrice, conditions_.floorPrice);
        // consumation timeframe
        assertEq(
            savedConditions.paymentTerms.consummationSaleTimeframe,
            conditions_.paymentTerms.consummationSaleTimeframe
        );
        // payment extras
        assertEq(savedExtras.label, extras_.label);
        assertEq(
            savedExtras.customTermDescription,
            extras_.customTermDescription
        );
    }
}
