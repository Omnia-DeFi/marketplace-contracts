// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OwnableAsset} from "./OwnableAsset.sol";

/**
 * @notice Contract that allows a seller to approve a buy request that
 *         was placed off-chain by a specific buyer.
 *         Approving a sale request will lead to a deposit triggered by
 *         the Marketplace.
 */
abstract contract OfferApproval is OwnableAsset {
    event OfferApprovedAtFloorPrice(
        AssetNft indexed asset,
        Approval indexed approval
    );
    event OfferApprovedAtCustomPrice(
        AssetNft indexed asset,
        Approval indexed approval,
        uint256 indexed price
    );
    event OfferApprovalReset(AssetNft indexed asset, uint256 timestamp);

    struct Approval {
        address seller;
        address buyer;
        bool atFloorPrice;
        uint256 price;
        uint256 approvalTimestamp;
        SaleConditions.Conditions conditions;
        SaleConditions.ExtraSaleTerms extras;
        bool ownerSignature;
    }

    mapping(AssetNft => Approval) public approvedOfferOf;

    /**
     * @notice Only approve an offer if there is none other approved.
     * @dev Checks that one or many parameters of struct Approval are not set.
     */
    modifier oneOfferApprovalPerAsset(AssetNft asset) {
        if (
            approvedOfferOf[asset].buyer != address(0) ||
            approvedOfferOf[asset].price != 0 ||
            approvedOfferOf[asset].approvalTimestamp != 0 ||
            approvedOfferOf[asset].ownerSignature
        ) revert("ALREADY_APPROVED");
        _;
    }

    /**
     * @notice Save a buy request for a specific NFT asset at floor
     *         price.
     *
     * @param asset The adress of the asset NFT repository.
     * @param buyer The buyer's address.
     * @param conditions Conditions of the sale for this asset.
     */
    function _approveSaleOfAtFloorPrice(
        AssetNft asset,
        address buyer,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) internal onlyAssetOwner(asset) oneOfferApprovalPerAsset(asset) {
        approvedOfferOf[asset].seller = msg.sender;
        approvedOfferOf[asset].buyer = buyer;
        approvedOfferOf[asset].atFloorPrice = true;
        approvedOfferOf[asset].price = conditions.floorPrice;
        approvedOfferOf[asset].approvalTimestamp = block.timestamp;
        approvedOfferOf[asset].conditions = conditions;
        approvedOfferOf[asset].extras = extras;
        approvedOfferOf[asset].ownerSignature = true;

        emit OfferApprovedAtFloorPrice(asset, approvedOfferOf[asset]);
    }

    /**
     * @notice Save a buy request for a specific NFT asset with a custom
     *         price agreed off-chain with the buyer.
     *
     * @param asset The adress of the asset NFT repository.
     * @param buyer The buyer's address.
     * @param salePrice Price agreed off-chain by both parties.
     * @param conditions Conditions of the sale for this asset.
     */
    function _approveSaleOfAtCustomPrice(
        AssetNft asset,
        address buyer,
        uint256 salePrice,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) internal onlyAssetOwner(asset) oneOfferApprovalPerAsset(asset) {
        approvedOfferOf[asset].seller = msg.sender;
        approvedOfferOf[asset].buyer = buyer;
        approvedOfferOf[asset].atFloorPrice = false;
        approvedOfferOf[asset].price = salePrice;
        approvedOfferOf[asset].approvalTimestamp = block.timestamp;
        approvedOfferOf[asset].conditions = conditions;
        approvedOfferOf[asset].extras = extras;
        approvedOfferOf[asset].ownerSignature = true;

        emit OfferApprovedAtCustomPrice(
            asset,
            approvedOfferOf[asset],
            salePrice
        );
    }

    function _resetAssetOfferApproval(AssetNft asset) internal {
        delete approvedOfferOf[asset];

        emit OfferApprovalReset(asset, block.timestamp);
    }
}
