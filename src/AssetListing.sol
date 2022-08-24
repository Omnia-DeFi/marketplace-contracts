// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {IAssetListing} from "./interfaces/IAssetListing.sol";
import {ISaleConditions} from "./interfaces/ISaleConditions.sol";
import "./libraries/ListingLib.sol";
import {Marketplace} from "./Marketplace.sol";

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
contract AssetListing is IAssetListing {
    Marketplace public marketplace;

    mapping(AssetNft => Listing) public listingOf;

    constructor(Marketplace marketplace_) {
        marketplace = marketplace_;
    }

    modifier onlyAssetOwner(AssetNft assetNft) {
        // require(assetNft.owner(assetId) == msg.sender, "NOT_OWNER");
        _;
    }

    /// @inheritdoc IAssetListing
    function listAsset(
        AssetNft asset,
        ISaleConditions.Conditions memory conditions,
        ISaleConditions.ExtraSaleTerms memory extras
    ) external onlyAssetOwner(asset) {
        Listing memory listing;

        listing.conditions = conditions;
        listing.extras = extras;
        listing.status = ListingLib.Status.ActiveListing;

        listingOf[asset] = listing;

        marketplace.saleConditions().setSaleConditions(
            asset,
            conditions,
            extras
        );

        emit AssetListed(
            asset,
            listing.conditions,
            listing.extras,
            listing.status
        );
    }

    /// @inheritdoc IAssetListing
    function unlistAsset(
        AssetNft asset,
        ISaleConditions conditions,
        ListingLib.Status listingStatus
    ) external returns (bool) {}
}
