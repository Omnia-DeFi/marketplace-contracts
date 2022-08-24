// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ISaleConditions} from "../src/interfaces/ISaleConditions.sol";
import {AssetListing} from "../src/AssetListing.sol";
import "../src/libraries/ListingLib.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";

contract AssetListingTest is Test {
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
    AssetListing public listing;
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
        nftAsset = new MockAssetNft(owner);
        marketplace = new MockMarketplace();
        listing = new AssetListing(marketplace);
    }

    function testOnlyOwnerCanListAsset() external {}

    function testEventEmittanceAssetListed() external {
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
}
