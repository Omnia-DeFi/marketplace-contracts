// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OfferApproval} from "./OfferApproval.sol";
import {OwnableAsset} from "./OwnableAsset.sol";

/**
 * @notice Once, the asset offer has been approved by the seller it
 *         triggers a deposit ask for both sides, starting with the buyer,
 *         and informs users about the deposit status.
 *
 *         The buyer has to deposit the whole amount of the asset offer.
 */
contract Deposit {
    event DepositAsked(
        AssetNft indexed asset,
        OfferApproval indexed approval,
        SaleConditions indexed conditions
    );
    event BuyerDeposit(
        address buyer,
        address indexed asset,
        string indexed currency,
        uint256 indexed amount
    );
    event SellerDeposit(address indexed asset);

    enum DepositStatus {
        Void,
        Pending,
        BuyerFullDeposit,
        SellerFullDeposit,
        AllDepositCompleted
    }

    struct DepositState {
        DepositStatus[] statuses;
        bool isAssetLocked;
    }

    /**
     * @notice Ask both parties engaged in the sale to deposit their
     *         due, starting with the buyer.
     *
     * @param asset The contract representing the asset.
     * @param approval The approval of the asset offer.
     * @param conditions The conditions of the sale.
     */
    function _emitDepositAsk(
        AssetNft asset,
        OfferApproval approval,
        SaleConditions conditions
    ) internal {}

    /**
     * @notice Whole deposit on both sides to consumme the sale.
     * @dev Parameters, see `emitDepositAsk()`.
     *      If `msg.sender`is the buyer only deposit the asset offer
     *      price minus the deposit (if any).
     *      If  `msg.sender`is the seller, desposit the NFTs
     */
    function _wholeDeposit(
        AssetNft asset,
        OfferApproval approval,
        SaleConditions conditions
    ) internal {}

    /**
     * @notice Inform about the curent state of the deposit.
     * @dev Parameters, see `emitDepositAsk()`.
     * @return DepositState enum, representing the current state of the deposit mentionning
     *         which party has already deposited.
     */
    function _depositState(
        AssetNft asset,
        OfferApproval approval,
        SaleConditions conditions
    ) internal view returns (DepositState memory) {}
}
