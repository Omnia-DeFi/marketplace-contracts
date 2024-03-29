// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {OwnableAsset} from "./OwnableAsset.sol";
import {AssetNft} from "omnia-nft/AssetNft.sol";
import "./libraries/ListingLib.sol";

/**
 * @notice The asset owner list an asset on the Marketplace while
 *         settting up sale's condtions (price, payment terms & extras).
 *
 *         The asset can be unlisted by the Marketplace according to
 *         SaleConditions or SaleConsummation.
 */
abstract contract AssetListing is OwnableAsset {
    event AssetListed(AssetNft indexed asset, ListingLib.Status indexed status);
    event AssetUnlisted(
        AssetNft indexed asset,
        ListingLib.Status indexed status
    );

    mapping(AssetNft => ListingLib.Status) public listingStatusOf;

    modifier onlyUnlistedAsset(AssetNft asset) {
        require(
            listingStatusOf[asset] == ListingLib.Status.Unlisted,
            "ASSET_ALREADY_LISTED"
        );
        _;
    }

    // TODO: test edges cases with `onlyUnlistedAsset` adding
    /**
     * @notice List an asset on the Marketplace for sale with specific
     *         sale conditions.
     * @dev Only the asset owner can list an asset while porivding sale
     *      conditions.
     *
     * @param asset The asset to be listed on the Marketplace.
     */
    function _listAsset(AssetNft asset)
        internal
        onlyAssetOwner(asset)
        onlyUnlistedAsset(asset)
    {
        listingStatusOf[asset] = ListingLib.Status.ActiveListing;

        emit AssetListed(asset, listingStatusOf[asset]);
    }

    /**
     * @notice Unlist an asset from the Marketplace.
     *
     * @param asset The asset to be unlisted from the Marketplace.
     */
    function _unlistAsset(AssetNft asset) internal {
        listingStatusOf[asset] = ListingLib.Status.Unlisted;

        emit AssetUnlisted(asset, listingStatusOf[asset]);
    }
}
