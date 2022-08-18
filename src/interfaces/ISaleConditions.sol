// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

/**
 * @notice Set the conditions for a sale of a specific asset as soon as it get listed.
 *
 *         The owner can update the conditions at any point in time prior an offer
 *         approval.
 *         This means it is up to the buyer to find an agreement (off-chain) with the
 *         seller.
 */

interface ISaleConditions {
    struct PaymentTerms {
        uint256 minimumDeposit; // in USD
        uint256 depositReceiptTimeframe; // at least 8 hours
        uint256 consummationSaleTimeframe; // at least 1 day
    }

    struct Conditions {
        uint256 floorPrice; // price defined by the owner, in USD
        PaymentTerms paymentTerms;
        bytes32[] extras;
    }

    /**
     * @notice The seller (NFT asset owner) defines the conditions for the sale, which
     *         includes but not limited to: minmum deposit amount to lock the asset, the
     *         timeframe for the deposit, the timeframe for sale to be conclude, and any
     *         extra conditions that the seller requires.
     *
     * @param asset The adress of the asset NFT repository.
     * @param assetId The id of the specific asset NFT.
     * @param conditions The conditions of the sale.
     */
    function setSaleConditions(
        address asset,
        uint256 assetId,
        Conditions conditions
    ) external;

    /**
     * @notice The seller can update the conditions for the sale prior to the offer
     *         approval.
     *
     * @param asset The adress of the asset NFT repository.
     * @param assetId The id of the specific asset NFT.
     * @param conditions The conditions of the sale.
     */
    function updateSaleConditions(
        address asset,
        uint256 assetId,
        Conditions conditions
    ) external;
}
