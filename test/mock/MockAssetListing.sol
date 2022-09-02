// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetListing, AssetNft} from "../../src/AssetListing.sol";
import "../../src/libraries/ListingLib.sol";

contract MockAssetListing is AssetListing {
    function listAsset(AssetNft asset) public {
        _listAsset(asset);
    }

    function setUpWithMockedData(AssetNft asset)
        public
        returns (ListingLib.Status)
    {
        _setUpWithMockedData(asset);

        return listingStatusOf[asset];
    }

    function _setUpWithMockedData(AssetNft asset) public {
        listingStatusOf[asset] = ListingLib.Status.ActiveListing;
    }
}
