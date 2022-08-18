// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {ISaleConditions} from "./ISaleConditions.sol";

/**
 * @notice Contract that allows a seller to approve a buy request that was placed off-chain
 *         by a specific buyer.
 */
interface IAssetOfferApproval {
    struct FullSaleOfferApproval {
        address assetOwner;
        address buyer;
        uint256 price;
        bool isFloorPrice;
        uint256 approvalTimestamp;
        ISaleConditions conditions;
        bool ownerSignature; // TODO: add owner signature
    }

    /**
     * @notice Save a buy request for a full sale of a specific NFT asset at floor price.
     *
     * @param asset The adress of the asset NFT repository.
     * @param assetId The id of the specific asset NFT.
     * @param buyer The buyer's address.
     * @param salePrice Price agreed off-chain by both parties.
     */
    // TODO: pass owner's signature
    function fullSaleApprovalAtFloorPriceOf(
        address asset,
        uint256 assetId,
        address buyer
    ) external;

    /**
     * @notice Save a buy request for a full sale of a specific NFT asset with a price
     *         different from the floor price and agreed off-chain with the buyer.
     *
     * @param asset The adress of the asset NFT repository.
     * @param assetId The id of the specific asset NFT.
     * @param buyer The buyer's address.
     * @param salePrice Price agreed off-chain by both parties.
     */
    // TODO: pass owner's signature
    function fullSaleApprovalWithCustomPriceOf(
        address asset,
        uint256 assetId,
        address buyer,
        uint256 salePrice
    ) external;
}
