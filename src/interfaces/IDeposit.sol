// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {IAssetOfferApproval} from "./IAssetOfferApproval.sol";
import {ISaleConditions} from "./ISaleConditions.sol";

interface IDeposit {
    event DepositAsked(
        AssetNft indexed asset,
        IAssetOfferApproval indexed approval,
        ISaleConditions indexed conditions
    );
    event BuyerDeposit(
        address buyer,
        address indexed asset,
        string indexed currency,
        uint256 indexed amount
    );
    event SellerDeposit(address indexed asset);

    enum DepositStatus {
        Pending,
        BuyerPartialDeposit,
        BuyerFullDeposit,
        SellerFullDeposit
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
    function emitDepositAsk(
        AssetNft asset,
        IAssetOfferApproval approval,
        ISaleConditions conditions
    ) external;

    /**
     * @notice The buyer will deposit at least the minimum amount of the
     *         desposit to lock the asset.
     * @dev Read the data from AssetOfferApproval to verify the sale
     *      conditions are still met (e.g. sale timeframe).
     */
    function partialBuyerDepositToLockAsset(uint256 amount, address currency)
        external;

    /**
     * @notice Whole deposit on both sides to consumme the sale.
     * @dev Parameters, see `emitDepositAsk()`.
     *      If `msg.sender`is the buyer only deposit the asset offer
     *      price minus the deposit (if any).
     *      If  `msg.sender`is the seller, desposit the NFTs
     */
    function wholeDeposit(
        AssetNft asset,
        IAssetOfferApproval approval,
        ISaleConditions conditions
    ) external;

    /**
     * @notice Inform about the curent state of the deposit.
     * @dev Parameters, see `emitDepositAsk()`.
     * @return Which partie(s) has not deposited.
     */
    function depositState(
        AssetNft asset,
        IAssetOfferApproval approval,
        ISaleConditions conditions
    ) external view returns (DepositState memory);
}
