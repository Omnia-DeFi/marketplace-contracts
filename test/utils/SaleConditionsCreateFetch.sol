// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {SaleConditions, AssetNft} from "../../src/SaleConditions.sol";

library SaleConditionsCreateFetch {
    function createdDefaultSaleConditions()
        public
        view
        returns (
            SaleConditions.Conditions memory conditions_,
            SaleConditions.ExtraSaleTerms memory extras_
        )
    {
        conditions_.floorPrice = 650000 * 100;
        conditions_.paymentTerms.consummationSaleTimeframe = 24 hours;

        extras_.label = "RandomLabel";
        extras_.customTermDescription = "short";
    }

    function createSpecificSaleConditions(
        uint256 floorPrice,
        uint256 consummationSaleTimeframe,
        string memory label,
        string memory description
    )
        public
        view
        returns (
            SaleConditions.Conditions memory conditions,
            SaleConditions.ExtraSaleTerms memory extras
        )
    {
        conditions.floorPrice = 650000 * 100;
        conditions.paymentTerms.consummationSaleTimeframe = 24 hours;

        extras.label = label;
        extras.customTermDescription = description;
    }

    function saleConditionsOf(SaleConditions sale, AssetNft asset)
        public
        view
        returns (
            SaleConditions.Conditions memory conditions,
            SaleConditions.ExtraSaleTerms memory extras
        )
    {
        (
            uint256 savedFloorPrice,
            SaleConditions.PaymentTerms memory paymentTerms
        ) = sale.saleConditionsOf(asset);
        conditions.floorPrice = savedFloorPrice;
        conditions.paymentTerms = paymentTerms;

        (string memory savedLabel, string memory savedeTermDescription) = sale
            .extraSaleConditionsOf(asset);
        extras.label = savedLabel;
        extras.customTermDescription = savedeTermDescription;
    }
}
