// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OfferApproval} from "./OfferApproval.sol";
import {Deposit} from "./Deposit.sol";

/**
 * @notice Once all sale conditions are met, the sale of the asset is
 *         consummated and the swap is instantly made. Each side can
 *         then claim their respective assets.
 */
contract SaleConsummation {
    event SaleConsummated(
        address indexed asset,
        address indexed buyer,
        SaleConditions indexed conditions,
        Deposit deposit
    );

    /**
     * @notice Consummate the sale of the asset to trigger the swap of
     *         assets deposited into the Deposit contract.
     *
     * @param asset The asset to be consummated.
     * @param buyer The buyer of the asset.
     * @param conditions The sale conditions of the asset.
     * @param deposit The deposit contractcontaing the currency and the
     *                NFTs.
     *
     * @return Sale consummation success or failure.
     */
    function _consummateSale(
        address asset,
        address buyer,
        SaleConditions conditions,
        Deposit deposit
    ) internal returns (bool) {}
}
