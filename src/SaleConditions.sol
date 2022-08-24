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
    mapping(AssetNft => Conditions) public saleConditionsOf;
    mapping(AssetNft => ExtraSaleTerms) public extraSaleConditionsOf;

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyAssetOwner(AssetNft assetNft) {
        // require(assetNft.owner(assetId) == msg.sender, "NOT_OWNER");
        _;
    }

    modifier saleConditionsFormat(
        ISaleConditions.Conditions memory conditions
    ) {
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

    /// @inheritdoc ISaleConditions
    function setSaleConditions(
        AssetNft asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    )
        external
        onlyAssetOwner(asset)
        saleConditionsFormat(conditions)
        extraTermsFormat(extras)
        existingSaleConditions(asset)
    {
        saleConditionsOf[asset] = conditions;
        extraSaleConditionsOf[asset] = extras;

        emit SaleConditionsSet(asset, conditions, extras);
    }

    /// @inheritdoc ISaleConditions
    function updateSaleConditions(
        address asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) external {}
}
