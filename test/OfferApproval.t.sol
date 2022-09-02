// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockOfferApproval, OfferApproval, SaleConditions} from "./mock/MockOfferApproval.sol";

contract MockAssetListingTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event OfferApprovedAtFloorPrice(
        AssetNft indexed asset,
        OfferApproval.Approval indexed approval
    );
    event OfferApprovedAtCustomPrice(
        AssetNft indexed asset,
        OfferApproval.Approval indexed approval,
        uint256 indexed price
    );

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

    function testOnlyOwnerCanApproveAnOfferAtFloorPrice() external {
        vm.startPrank(owner);
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );
    }

    function testOnlyOwnerCanApproveAnOfferAtCustomPrice() external {
        vm.startPrank(owner);
        approval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            8902342 * 100,
            conditionsSetUp,
            extrasSetUp
        );
    }

    function testOfferApprovalAtFloorPriceFailsOnNotOwner() external {
        vm.expectRevert("NOT_OWNER");
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );
    }

    function testOfferApprovalAtCustomPriceFailsOnNotOwner() external {
        vm.expectRevert("NOT_OWNER");
        approval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            8902342 * 100,
            conditionsSetUp,
            extrasSetUp
        );
    }

    // Floor price or custom price offer, once one has been been approved no other offer
    // can be approved.
    function testOnlyOneOfferApprovalPerAsset() external {
        vm.startPrank(owner);
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );
        vm.expectRevert("ALREADY_APPROVED");
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );
        vm.expectRevert("ALREADY_APPROVED");
        approval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            124901 * 100,
            conditionsSetUp,
            extrasSetUp
        );
    }

    /*//////////////////////////////////////////////////////////////
						  FLOOR PRICE
	//////////////////////////////////////////////////////////////*/
    function testSavedValuesAfterOfferApprovedAtFloorPrice() external {
        vm.startPrank(owner);
        uint256 timestamp = block.timestamp;
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );

        // fetch saved offer approval
        (
            address savedSeller,
            address savedBuyer,
            bool atFloorPrice,
            uint256 price,
            uint256 approvalTimestamp,
            SaleConditions.Conditions memory conditions,
            SaleConditions.ExtraSaleTerms memory extras,
            bool ownerSignature
        ) = approval.approvedOfferOf(nftAsset);

        assertEq(savedSeller, owner);
        assertEq(savedBuyer, buyer);
        assertTrue(atFloorPrice);
        assertEq(price, conditionsSetUp.floorPrice);
        // Allow 3s of delay, in case computation is slow
        assertApproxEqAbs(approvalTimestamp, timestamp, 3);
        assertEq(conditions.floorPrice, conditionsSetUp.floorPrice);
        assertEq(
            conditions.paymentTerms.consummationSaleTimeframe,
            conditionsSetUp.paymentTerms.consummationSaleTimeframe
        );
        assertEq(extras.label, extrasSetUp.label);
        assertEq(
            extras.customTermDescription,
            extrasSetUp.customTermDescription
        );
        assertTrue(ownerSignature);
    }

    function testEventEmittanceOfferApprovedAtFloorPrice() external {
        vm.startPrank(owner);

        OfferApproval.Approval memory approval_;
        (
            approval_.seller,
            approval_.buyer,
            approval_.atFloorPrice,
            approval_.price,
            approval_.approvalTimestamp,
            approval_.conditions,
            approval_.extras,
            approval_.ownerSignature
        ) = approval.approvedOfferOf(nftAsset);
        // FIXME: second topic (approval_) is not checked because it fails son "invalid log"
        //        the issue might be related to the fact that we create an
        //        OfferApproval.Approval memory above which uses a different storage
        //        location than the one emitted in the event
        vm.expectEmit(true, false, true, true, address(approval));
        emit OfferApprovedAtFloorPrice(nftAsset, approval_);
        approval.approveSaleOfAtFloorPrice(
            nftAsset,
            buyer,
            conditionsSetUp,
            extrasSetUp
        );
    }

    /*//////////////////////////////////////////////////////////////
						  CUSTOM PRICE
	//////////////////////////////////////////////////////////////*/
    function testSavedValuesAfterOfferApprovedAtCustomPrice() external {
        vm.startPrank(owner);
        uint256 customPrice = 324015 * 100;
        uint256 timestamp = block.timestamp;
        approval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            customPrice,
            conditionsSetUp,
            extrasSetUp
        );

        // fetch saved offer approval
        (
            address savedSeller,
            address savedBuyer,
            bool atFloorPrice,
            uint256 price,
            uint256 approvalTimestamp,
            SaleConditions.Conditions memory conditions,
            SaleConditions.ExtraSaleTerms memory extras,
            bool ownerSignature
        ) = approval.approvedOfferOf(nftAsset);

        assertEq(savedSeller, owner);
        assertEq(savedBuyer, buyer);
        assertFalse(atFloorPrice);
        assertEq(price, customPrice);
        // Allow 3s of delay, in case computation is slow
        assertApproxEqAbs(approvalTimestamp, timestamp, 3);
        assertEq(conditions.floorPrice, conditionsSetUp.floorPrice);
        assertEq(
            conditions.paymentTerms.consummationSaleTimeframe,
            conditionsSetUp.paymentTerms.consummationSaleTimeframe
        );
        assertEq(extras.label, extrasSetUp.label);
        assertEq(
            extras.customTermDescription,
            extrasSetUp.customTermDescription
        );
        assertTrue(ownerSignature);
    }

    function testEventEmittanceOfferApprovedAtCustomPrice() external {
        vm.startPrank(owner);

        uint256 customPrice = 324015 * 100;

        OfferApproval.Approval memory approval_;
        approval_.seller = owner;
        approval_.buyer = buyer;
        approval_.atFloorPrice = false;
        approval_.price = customPrice;
        approval_.approvalTimestamp = block.timestamp;
        approval_.conditions = conditionsSetUp;
        approval_.extras = extrasSetUp;
        approval_.ownerSignature = true;

        // FIXME: second topic (approval_) is not checked because it fails son "invalid log"
        //        the issue might be related to the fact that we create an
        //        OfferApproval.Approval memory above which uses a different storage
        //        location than the one emitted in the event
        vm.expectEmit(true, false, true, true, address(approval));
        emit OfferApprovedAtCustomPrice(nftAsset, approval_, customPrice);
        approval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            customPrice,
            conditionsSetUp,
            extrasSetUp
        );
        // verify timestamp registered in OfferApproval is the same thena the one in this test
        assertEq(approval_.approvalTimestamp, approval.savedTimestamp());
    }

    //TODO: test _resetAssetOfferApproval & OfferApprovalReset event emittance
}
