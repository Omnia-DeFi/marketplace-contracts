// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {SaleConsummation, AssetNft, SaleConditions, OfferApproval, Deposit} from "../../src/SaleConsummation.sol";

contract MockSaleConsummation is SaleConsummation {
    function consummateSale(
        address asset,
        address buyer,
        SaleConditions conditions,
        Deposit deposit
    ) external returns (bool) {
        _consummateSale(asset, buyer, conditions, deposit);
    }
}
