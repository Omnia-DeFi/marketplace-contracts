// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {ISaleConditions} from "./ISaleConditions.sol";
import "../libraries/ListingLib.sol";

interface IAssetListing {
    event AssetListed(AssetNft indexed asset, ListingLib.Status indexed status);
    event AssetUnlisted(
        AssetNft indexed asset,
        ListingLib.Status indexed status
    );

    /**
     * @notice List an asset on the Marketplace for sale with specific
     *         sale conditions.
     * @dev Only the asset owner can list an asset while porivding sale
     *      conditions.
     *
     * @param asset The asset to be listed on the Marketplace.
     */
    function listAsset(AssetNft asset) external;

    /**
     * @notice Unlist an asset from the Marketplace.
     * @dev Only the SaleConditions can unlist an asset.
     *
     * @param asset The asset to be listed on the Marketplace.
     * @param listingStatus The asset listing status with the reason of
     *        the unlisting.
     */
    function unlistAsset(AssetNft asset, ListingLib.Status listingStatus)
        external
        returns (bool);
}
