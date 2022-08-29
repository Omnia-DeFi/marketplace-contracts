// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockOfferApproval, SaleConditions} from "./mock/MockOfferApproval.sol";

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
    MockOfferApproval public approval;
    SaleConditions.Conditions conditionsSetUp;
    SaleConditions.ExtraSaleTerms extrasSetUp;

    address immutable owner = msg.sender;
    address buyer = 0x065e3DbaFCb2C26A978720f9eB4Bce6aD9D644a1;

    function createBaseSaleConditions() public {
        conditionsSetUp.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        conditionsSetUp.paymentTerms.consummationSaleTimeframe = 24 hours;
    }

    function setUp() public {
        nftAsset = new AssetNft("AssetMocked", "MA1", owner);
        marketplace = new MockMarketplace();
        approval = new MockOfferApproval();

        vm.prank(owner);
        nftAsset.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );
    }

    function testOnlyOwnerCanApproveAnOffer() external {
        vm.startPrank(owner);
        // at floor price
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );
        // custom price
        approval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            8902342 * 100,
            conditionsSetUp,
            extrasSetUp
        );
    }

    function testOfferApprvoalFailsOnNotOwner() external {
        // at floor price
        vm.expectRevert("NOT_OWNER");
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );
        // custom price
        vm.expectRevert("NOT_OWNER");
        approval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            8902342 * 100,
            conditionsSetUp,
            extrasSetUp
        );
    }
    function testOnlyOwnerCanApproveAnOffer() external {}
}
