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
    event DepositAsked(AssetNft indexed asset, DepositState indexed approval);
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
        AllDepositMade
    }

    struct DepositState {
        DepositStatus status;
        bool isAssetLocked;
        OfferApproval.Approval approval;
    }

    mapping(AssetNft => DepositState) public depositStateOf;

    /**
     * @notice Ask both parties engaged in the sale to deposit their
     *         due, starting with the buyer.
     * @dev DepositState.isAssetLocked is set to false by default.
     *
     * @param asset The contract representing the asset.
     * @param approval The approval of the asset offer.
     */
    function _emitDepositAsk(
        AssetNft asset,
        OfferApproval.Approval memory approval
    ) internal {
        // Update status and approval. Asset is not locked as not deposit has beeen made
        // yet. By default a bollean is false, so no need to update it to false.
        depositStateOf[asset].status = DepositStatus.Pending;
        depositStateOf[asset].approval = approval;

        emit DepositAsked(asset, depositStateOf[asset]);
    }

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
     *         which party has already deposited and if the asset is locked for the buyer.
     */
    function _depositState(
        AssetNft asset,
        OfferApproval approval,
        SaleConditions conditions
    ) internal view returns (DepositState memory) {}
}
