// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {SaleConditions} from "./SaleConditions.sol";

/**
 * @notice Contract that allows a seller to approve a buy request that
 *         was placed off-chain by a specific buyer.
 *         Approving a sale request will lead to a deposit triggered by
 *         the Marketplace.
 */
contract OfferApproval {
    event OfferApprovedAtFloorPrice(
        AssetNft indexed asset,
        OfferApproval indexed approval
    );
    event OfferApprovedAtCustomPrice(
        AssetNft indexed asset,
        OfferApproval indexed approval
    );

    struct OfferApproval {
        address assetOwner;
        address buyer;
        bool atFloorPrice;
        uint256 price;
        uint256 approvalTimestamp;
        SaleConditions.Conditions conditions;
        SaleConditions.ExtraSaleTerms extras;
        bool ownerSignature; // TODO: add owner's signature
    }

    /**
     * @notice Save a buy request for a specific NFT asset at floor
     *         price.
     *
     * @param asset The adress of the asset NFT repository.
     * @param buyer The buyer's address.
     * @param conditions Conditions of the sale for this asset.
     */
    // TODO: pass owner's signature
    function _approveSaleOfAtFloorPrice(
        AssetNft asset,
        address buyer,
        SaleConditions conditions
    ) internal {}

    /**
     * @notice Save a buy request for a specific NFT asset with a custom
     *         price agreed off-chain with the buyer.
     *
     * @param asset The adress of the asset NFT repository.
     * @param buyer The buyer's address.
     * @param salePrice Price agreed off-chain by both parties.
     * @param conditions Conditions of the sale for this asset.
     */
    // TODO: pass owner's signature
    function _approveSaleOfAtCustomPrice(
        AssetNft asset,
        address buyer,
        uint256 salePrice,
        SaleConditions conditions
    ) internal {}
}
