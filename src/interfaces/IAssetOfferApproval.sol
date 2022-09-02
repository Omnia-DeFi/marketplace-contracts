// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {ISaleConditions} from "./ISaleConditions.sol";

interface IAssetOfferApproval {
    event OfferApprovedAtFloorPrice(
        address indexed asset,
        address indexed buyer,
        ISaleConditions indexed conditions
    );
    event OfferApprovedAtCustomPrice(
        address indexed asset,
        address indexed buyer,
        uint256 indexed salePrice,
        ISaleConditions conditions
    );

    struct FloorPriceOfferApproval {
        address assetOwner;
        address buyer;
        uint256 approvalTimestamp;
        ISaleConditions conditions;
        bool ownerSignature; // TODO: add owner's signature
    }
    struct CustomPriceOfferApproval {
        address assetOwner;
        address buyer;
        bool atFloorPrice;
        uint256 price;
        uint256 approvalTimestamp;
        ISaleConditions conditions;
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
    function approveSaleOfAtFloorPrice(
        address asset,
        address buyer,
        ISaleConditions conditions
    ) external;

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
    function approveSaleOfAtCustomPrice(
        address asset,
        address buyer,
        uint256 salePrice,
        ISaleConditions conditions
    ) external;
}
