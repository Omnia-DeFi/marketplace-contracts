// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {AssetNft, ListingLib, AssetListing, SaleConditions, OfferApproval, Deposit} from "../../src/Marketplace.sol";

contract EmptyValueTest is Test {
    function verifiesAssetIsNotListed(AssetListing listing, AssetNft asset)
        public
    {
        assertTrue(
            listing.listingStatusOf(asset) == ListingLib.Status.Unlisted
        );
    }

    function verifySaleCondtionsAreEmpty(SaleConditions sale, AssetNft asset)
        public
    {
        // fetch Conditions
        (
            uint256 floorPrice,
            SaleConditions.PaymentTerms memory paymentTerms
        ) = sale.saleConditionsOf(asset);
        // fetch ExtrasConditions
        (string memory label, string memory customTermDescription) = sale
            .extraSaleConditionsOf(asset);

        assertTrue(floorPrice == 0);
        assertTrue(paymentTerms.consummationSaleTimeframe == 0);
        assertTrue(bytes(label).length == 0);
        assertTrue(bytes(customTermDescription).length == 0);
    }

    function verifyAssetOfferAprovalIsEmpty(
        OfferApproval approval,
        AssetNft asset
    ) public {
        (
            address seller,
            address buyer,
            bool atFloorPrice,
            uint256 price,
            uint256 approvalTimestamp,
            SaleConditions.Conditions memory conditions,
            SaleConditions.ExtraSaleTerms memory extras,
            bool ownerSignature
        ) = approval.approvedOfferOf(asset);

        assertTrue(seller == address(0));
        assertTrue(buyer == address(0));
        assertTrue(atFloorPrice == false);
        assertTrue(price == 0);
        assertTrue(approvalTimestamp == 0);
        assertTrue(conditions.floorPrice == 0);
        assertTrue(conditions.paymentTerms.consummationSaleTimeframe == 0);
        assertTrue(bytes(extras.label).length == 0);
        assertTrue(bytes(extras.customTermDescription).length == 0);
        assertTrue(ownerSignature == false);
    }

    function verifyDepositDataAreEmpty(Deposit deposit, AssetNft asset) public {
        (
            Deposit.DepositState memory dS,
            Deposit.ApprovalResume memory aR,
            Deposit.BuyerData memory bD,
            Deposit.SellerData memory sD
        ) = deposit.depositedDataOf(asset);

        // DepositState
        assertTrue(uint256(dS.status) == uint256(Deposit.DepositStatus.Void));
        assertTrue(dS.isAssetLocked == false);
        // ApprovalResume
        assertTrue(aR.seller == address(0));
        assertTrue(aR.buyer == address(0));
        assertTrue(aR.price == 0);
        // BuyerData
        assertTrue(bD.currencyAddress == address(0));
        assertTrue(bytes(bD.symbol).length == 0);
        assertTrue(bD.amount == 0);
        // SellerData
        assertTrue(sD.hasSellerDepositedAll == false);
        assertTrue(sD.amount == 0);
    }
}
