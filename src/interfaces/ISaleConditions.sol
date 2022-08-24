// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";

interface ISaleConditions {
    struct PaymentTerms {
        uint256 consummationSaleTimeframe; // at least 1 day
    }
    struct Conditions {
        uint256 floorPrice; // price defined by the owner, in USD
        PaymentTerms paymentTerms;
    }
    struct ExtraSaleTerms {
        string label;
        string customTerm;
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
    function setSaleConditions(
        AssetNft asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) external;

    /**
     * @notice The seller can update the conditions for the sale prior
     *         to an deposit.
     * @dev Same parameters as `setSaleConditions()`.
     */
    function updateSaleConditions(
        address asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) external;
}
