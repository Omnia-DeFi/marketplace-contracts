// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {OfferApproval, AssetNft, SaleConditions} from "../../src/OfferApproval.sol";

contract MockOfferApproval is OfferApproval {
    uint256 public savedTimestamp;

    function approveSaleOfAtFloorPrice(
        AssetNft asset,
        address buyer,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public {
        _approveSaleOfAtFloorPrice(asset, buyer, conditions, extras);
        savedTimestamp = block.timestamp;
    }

    function approveSaleOfAtCustomPrice(
        AssetNft asset,
        address buyer,
        uint256 salePrice,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public {
        _approveSaleOfAtCustomPrice(
            asset,
            buyer,
            salePrice,
            conditions,
            extras
        );
        savedTimestamp = block.timestamp;
    }

    function setUpWithMockedData(
        AssetNft asset,
        address seller,
        address buyer,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public returns (Approval memory) {
        _setUpWithMockedData(asset, seller, buyer, conditions, extras);

        return (approvedOfferOf[asset]);
    }

    function _setUpWithMockedData(
        AssetNft asset,
        address seller,
        address buyer,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public {
        approvedOfferOf[asset].seller = seller;
        approvedOfferOf[asset].buyer = buyer;
        // price
        approvedOfferOf[asset].atFloorPrice = true;
        approvedOfferOf[asset].price = conditions.floorPrice;
        // timestamp
        approvedOfferOf[asset].approvalTimestamp = block.timestamp;
        // SaleConditions
        approvedOfferOf[asset].conditions = conditions;
        approvedOfferOf[asset].extras = extras;
        // Approval from owner
        approvedOfferOf[asset].ownerSignature = true;
    }
}
