// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {AssetListing} from "./AssetListing.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OfferApproval} from "./OfferApproval.sol";
import {Deposit} from "./Deposit.sol";

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
    event SaleConsummated(
        address indexed asset,
        address indexed buyer,
        SaleConditions indexed conditions,
        Deposit deposit
    );

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/
    /// @dev USD price only has 2 decimals.
    uint256 public constant FIAT_PRICE_DECIMAL = 10**2;

    /**
     * @notice List an asset for sale on the marketplace with compulsory sale conditions
     *         and optional extra sale terms.
     * @dev Merge `AssetListing` & `SaleConditions` logic.
     */
    function listAssetWithSaleConditions(
        AssetNft asset,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public {
        _listAsset(asset);
        _setSaleConditions(asset, conditions, extras);
    }

    /**
     * @notice Once all sale conditions are met, the sale of the asset is
     *         consummated and the swap is instantly made. Each side wil
     *         receive their respective assets.
     *
     * @param asset The asset to be consummated.
     * @param buyer The buyer of the asset.
     * @param conditions The sale conditions of the asset.
     * @param deposit The deposit contractcontaing the currency and the
     *                NFTs.
     *
     * @return Sale consummation success or failure.
     */
    function consummateSale(
        address asset,
        address buyer,
        SaleConditions conditions,
        Deposit deposit
    ) external returns (bool) {}
}
