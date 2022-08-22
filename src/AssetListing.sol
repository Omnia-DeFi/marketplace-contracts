// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {IAssetListing} from "./interfaces/IAssetListing.sol";
import {ISaleConditions} from "./interfaces/ISaleConditions.sol";
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
    /// @inheritdoc IAssetListing
    function listAsset(
        AssetNft asset,
        ISaleConditions.Conditions memory conditions,
        ISaleConditions.ExtraSaleTerms memory extras
    ) external {}

    /// @inheritdoc IAssetListing
    function unlistAsset(
        AssetNft asset,
        ISaleConditions conditions,
        ListingStatus listingStatus
    ) external returns (bool) {}
}