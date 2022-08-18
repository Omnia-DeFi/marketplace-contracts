// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {ISaleConditions} from "./ISaleConditions.sol";
import {IAssetOfferApproval} from "./IAssetOfferApproval.sol";

/**
 * @notice Once, the asset offer has been approved by the seller it triggers a deposit ask
 *         for both sides and informs users about the deposit status.
 *
 *         The buyer has the choice to deposit a part of the asset offer or the whole
 *         amount in once.
 */

interface IDeposit {
    event DepositAsked(
        AssetNft indexed asset,
        ISaleConditions indexed conditions,
        IAssetOfferApproval indexed approval
    );

    /**
     * @notice Ask both parties engage in the sale to deposit their due.
     *
     * @param AssetNft The contract representing the asset.
     * @param ISaleConditions The conditions of the sale.
     * @param IAssetOfferApproval The approval of the asset offer.
     *
     * Emitts:
     * - DepositAsked event.
     */
    function emitDepositAsked(
        AssetNft asset,
        ISaleConditions conditions,
        IAssetOfferApproval approval
    ) external;

    /**
     * @notice The buyer will deposit at least the minimum amount of the desposit to lock
     *         the asset for themselves.
     *
     *         It verifies the sale conditions are still met (e.g. sale timeframe)
     *
     * @dev Read the data from AssetOfferApproval.
     *
     * Requirements:
     * - only the buyer registered in AssetOfferApproval can deposit.
     * - the deposited amount MUST be greater or equal to the minimum deposit amount.
     */
    function partialDepositToLockAsset(uint256 amount, address currency)
        external;

    /**
     * @notice Deposit the asset or the currency depending on `msg.sender`
     *         value.
     *
     *         It verifies the sale conditions are still met (e.g. sale timeframe)
     *
     * @dev Read the data from AssetOfferApproval.
     *      If the buyer has already made a deposit they can only deposit the rest.
     *
     * ⚠️ FRONTEND: Inform the buyer that this will deposit the whole amount of currency
     *             that matches with the approved asset offer.
     */
    function wholeDeposit() external;

    /**
     * @notice Inform about the deposit state.
     *
     * @dev Returns which partie(s) has not deposited.
     */
    function getDepositState() external view returns (address[]);
}
