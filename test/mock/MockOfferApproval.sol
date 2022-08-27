// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {OfferApproval, AssetNft, SaleConditions} from "../../src/OfferApproval.sol";

contract MockOfferApproval is OfferApproval {
    function approveSaleOfAtFloorPrice(
        AssetNft asset,
        address buyer,
        SaleConditions conditions
    ) public {
        _approveSaleOfAtFloorPrice(asset, buyer, conditions);
    }

    function approveSaleOfAtCustomPrice(
        AssetNft asset,
        address buyer,
        uint256 salePrice,
        SaleConditions conditions
    ) public {
        _approveSaleOfAtCustomPrice(asset, buyer, salePrice, conditions);
    }
}
