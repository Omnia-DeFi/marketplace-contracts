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
    Marketplace public marketplace;

    mapping(AssetNft => Conditions) public saleConditionsOf;
    mapping(AssetNft => ExtraSaleTerms) public extraSaleConditionsOf;

    constructor(Marketplace marketplace_) {
        marketplace = marketplace_;
    }

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyAssetOwner(AssetNft assetNft) {
        // require(assetNft.owner(assetId) == msg.sender, "NOT_OWNER");
        _;
    }

    modifier minimalSaleConditions(
        ISaleConditions.Conditions memory conditions
    ) {
        require(conditions.floorPrice > 0, "ZERO_FLOOR_PRICE");
        require(
            conditions.paymentTerms.consummationSaleTimeframe >= 24 hours,
            "MIN_24H_SALE"
        );
        _;
    }

    modifier checkExtrasTerms(ExtraSaleTerms memory extras) {
        if (bytes(extras.label).length > 0) {
            require(bytes(extras.label).length >= 4, "4_CHAR_LABEL");
            require(bytes(extras.customTerm).length >= 4, "4_CHAR_TERM");
        }
        _;
    }

    modifier conditionsNotSetYet(AssetNft assetNft) {
        require(
            saleConditionsOf[assetNft].floorPrice == 0,
            "CONDITIONS_SET_PRICE"
        );
        require(
            saleConditionsOf[assetNft].paymentTerms.consummationSaleTimeframe ==
                0,
            "CONDITIONS_SET_TIME"
        );
        require(
            bytes(extraSaleConditionsOf[assetNft].label).length == 0,
            "EXTRAS_SET"
        );
        require(
            bytes(extraSaleConditionsOf[assetNft].customTerm).length == 0,
            "EXTRAS_SET"
        );
        _;
    }

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
