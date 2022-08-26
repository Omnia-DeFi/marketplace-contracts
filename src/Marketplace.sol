// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {AssetListing} from "./AssetListing.sol";
import {SaleConditions} from "./SaleConditions.sol";

/**
 * @notice Marketplace is the orchestrator contract. It is responsible
 *         to link all the contracts engaged in a sale from the listing
 *         to the swap of assets (currency <-> NFTs).
 *
 *         It also registers the currencies accepted to buy NFTs.
 *
 * @dev Connects AssetListing, SaleConditions, AssetOfferAproval,
 *      Deposit & SaleConsummation contracts together.
 */
contract Marketplace is AssetListing, SaleConditions {
    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/
    /// @dev USD price only has 2 decimals.
    uint256 public constant FIAT_PRICE_DECIMAL = 10**2;

    /*//////////////////////////////////////////////////////////////
                                 PRICING LOGIC
    //////////////////////////////////////////////////////////////*/
    mapping(string => address) public supportedCurrenciesAddress;
    mapping(address => string) public supportedCurrenciesTicker;

    function listAssetWithSaleConditions(
        AssetNft asset,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public {
        listAsset(asset);
        setSaleConditions(asset, conditions, extras);
    }
}
