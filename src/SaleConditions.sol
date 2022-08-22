// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/ISaleConditions.sol";
import {Marketplace} from "./Marketplace.sol";

/**
 * @notice Set the conditions for a sale of a specific asset as soon as
 *         it get listed.
 *
 *         The seller can update the conditions at any point in time
 *         prior a deposit. It is up to the buyer to find an (off-chain)
 *         agreement with the seller.
 *
 * @dev This contract can update the listing status if an asset in the
 *      Marketplace depending on conditions, such as: deposit made to
 *      lock the asset, sale  consummated, sale cancelled, sale voided
 *      (before desposit), etc...
 */
contract SaleConditions is ISaleConditions {
    /// @inheritdoc ISaleConditions
    function setSaleConditions(
        AssetNft asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) external {}

    /// @inheritdoc ISaleConditions
    function updateSaleConditions(
        address asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) external {}
}
