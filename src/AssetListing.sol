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
 *         SaleConditions.
 *
 *         The asset can unlisted from the Marketplace if: a deposit
 *         has been made to lock the asset, the sale has been
 *         consummated or the sale has been cancelled.
 */
abstract contract AssetListing is OwnableAsset {
    event AssetListed(AssetNft indexed asset, ListingLib.Status indexed status);
    event AssetUnlisted(
        AssetNft indexed asset,
        ListingLib.Status indexed status
    );

    mapping(AssetNft => ListingLib.Status) public listingStatusOf;

    /**
     * @notice List an asset on the Marketplace for sale with specific
     *         sale conditions.
     * @dev Only the asset owner can list an asset while porivding sale
     *      conditions.
     *
     * @param asset The asset to be listed on the Marketplace.
     */
    function _listAsset(AssetNft asset) internal onlyAssetOwner(asset) {
        listingStatusOf[asset] = ListingLib.Status.ActiveListing;

        emit AssetListed(asset, listingStatusOf[asset]);
    }

    /**
     * @notice Unlist an asset from the Marketplace.
     * @dev Only the SaleConditions can unlist an asset.
     *
     * @param asset The asset to be listed on the Marketplace.
     * @param listingStatus The asset listing status with the reason of
     *        the unlisting.
     */
    function _unlistAsset(AssetNft asset, ListingLib.Status listingStatus)
        internal
        returns (bool)
    {}
}
