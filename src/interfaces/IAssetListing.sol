// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {ISaleConditions} from "./ISaleConditions.sol";
import "../libraries/ListingLib.sol";

interface IAssetListing {
    event AssetListed(
        AssetNft indexed asset,
        ISaleConditions.Conditions indexed conditions,
        ISaleConditions.ExtraSaleTerms indexed extras,
        ListingLib.Status status
    );
    event AssetUnlisted(
        AssetNft indexed asset,
        ISaleConditions indexed conditions,
        ListingLib.Status indexed status
    );

    /** @dev Save the listing of an assset on the Marketplace with
     *       conditions and status.
     */
    struct Listing {
        ISaleConditions.Conditions conditions;
        ISaleConditions.ExtraSaleTerms extras;
        ListingLib.Status status;
    }

    /**
     * @notice List an asset on the Marketplace for sale with specific
     *         sale conditions.
     * @dev Only the asset owner can list an asset while porivding sale
     *      conditions.
     *
     * @param asset The asset to be listed on the Marketplace.
     * @param conditions The sale conditions of the asset.
     * @param extras The extra sale terms of the asset.
     */
    function listAsset(
        AssetNft asset,
        ISaleConditions.Conditions memory conditions,
        ISaleConditions.ExtraSaleTerms memory extras
    ) external;

    /**
     * @notice Unlist an asset from the Marketplace.
     * @dev Only the SaleConditions can unlist an asset.
     *
     * @param asset The asset to be listed on the Marketplace.
     * @param conditions The sale conditions of the asset.
     * @param listingStatus The asset listing status with the reason of
     *        the unlisting.
     */
    function unlistAsset(
        AssetNft asset,
        ISaleConditions conditions,
        ListingLib.Status listingStatus
    ) external returns (bool);
}
