// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {Marketplace, AssetNft} from "src/Marketplace.sol";

contract MockMarketplace is Marketplace {
    function resetSale(AssetNft asset) public {
        _resetSale(asset);
    }
}
