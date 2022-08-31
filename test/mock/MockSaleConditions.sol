// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {SaleConditions, AssetNft} from "../../src/SaleConditions.sol";

contract MockSaleConditions is SaleConditions {
    uint256 constant DECIMALS = 100;

    function setSaleConditions(
        AssetNft asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) public {
        _setSaleConditions(asset, conditions, extras);
    }

    function setUpWithMockedData(AssetNft asset)
        public
        returns (Conditions memory, ExtraSaleTerms memory)
    {
        _setUpWithMockedData(asset);

        return (saleConditionsOf[asset], extraSaleConditionsOf[asset]);
    }

    function _setUpWithMockedData(AssetNft asset) public {
        saleConditionsOf[asset].floorPrice = 1249014 * DECIMALS;
        saleConditionsOf[asset]
            .paymentTerms
            .consummationSaleTimeframe = 24 hours;

        extraSaleConditionsOf[asset].label = "Label";
        extraSaleConditionsOf[asset]
            .customTermDescription = "Custom Description";
    }
}
