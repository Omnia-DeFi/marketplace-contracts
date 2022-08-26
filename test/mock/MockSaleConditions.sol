// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {SaleConditions, AssetNft} from "../../src/SaleConditions.sol";

contract MockSaleConditions is SaleConditions {
    function setSaleConditions(
        AssetNft asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) public {
        _setSaleConditions(asset, conditions, extras);
    }
}
