// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {OwnableAsset} from "./OwnableAsset.sol";

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
abstract contract SaleConditions is OwnableAsset {
    event SaleConditionsSet(
        AssetNft indexed asset,
        Conditions indexed conditions,
        ExtraSaleTerms indexed extras
    );

    struct PaymentTerms {
        uint256 consummationSaleTimeframe; // at least 1 day
    }
    struct Conditions {
        uint256 floorPrice; // price defined by the owner, in USD
        PaymentTerms paymentTerms;
    }
    struct ExtraSaleTerms {
        string label;
        string customTermDescription;
    }

    mapping(AssetNft => Conditions) public saleConditionsOf;
    mapping(AssetNft => ExtraSaleTerms) public extraSaleConditionsOf;

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier saleConditionsFormat(Conditions memory conditions) {
        require(conditions.floorPrice > 0, "ZERO_FLOOR_PRICE");
        require(
            conditions.paymentTerms.consummationSaleTimeframe >= 24 hours,
            "MIN_24H_SALE"
        );
        _;
    }

    modifier extraTermsFormat(ExtraSaleTerms memory extras) {
        if (bytes(extras.label).length > 0) {
            require(bytes(extras.label).length >= 4, "4_CHAR_LABEL");
            require(
                bytes(extras.customTermDescription).length >= 4,
                "4_CHAR_TERM"
            );
        }
        _;
    }

    /**
     * @dev if `floorPrice` is defined `consummationSaleTimeframe` is defined for sure due
     *      to `saleConditionsFormat` modifier.
     */
    modifier existingSaleConditions(AssetNft assetNft) {
        if (
            saleConditionsOf[assetNft].floorPrice > 0 &&
            saleConditionsOf[assetNft].paymentTerms.consummationSaleTimeframe >
            0
        ) revert("MIN_CONDITIONS_SET");
        _;
    }

    /**
     * @notice The seller (NFT asset owner) defines the conditions for
     *         the sale, which includes but not limited to: minmum
     *         deposit amount to lock the asset, the timeframe for the
     *         deposit, the timeframe for sale to be concluded, and any
     *         extra conditions that the seller requires.
     *
     * @param asset The adress of the asset NFT repository.
     * @param conditions The conditions of the sale.
     * @param extras Any extra terms required by the seller.
     */
    function _setSaleConditions(
        AssetNft asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    )
        internal
        onlyAssetOwner(asset)
        saleConditionsFormat(conditions)
        extraTermsFormat(extras)
        existingSaleConditions(asset)
    {
        saleConditionsOf[asset] = conditions;
        extraSaleConditionsOf[asset] = extras;

        emit SaleConditionsSet(asset, conditions, extras);
    }

    /**
     * @notice The seller can update the conditions for the sale prior
     *         to an deposit.
     * @dev Same parameters as `setSaleConditions()`.
     */
    function _updateSaleConditions(
        address asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) internal {}
}
