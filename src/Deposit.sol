// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {IAssetOfferApproval, ISaleConditions, IDeposit} from "./interfaces/IDeposit.sol";

/**
 * @notice Once, the asset offer has been approved by the seller it
 *         triggers a deposit ask for both sides, starting with the buyer,
 *         and informs users about the deposit status.
 *
 *         The buyer has the choice to deposit a part of price the offer
 *         or the whole amount at once.
 */
contract Deposit is IDeposit {
    /// @inheritdoc IDeposit
    function emitDepositAsk(
        AssetNft asset,
        IAssetOfferApproval approval,
        ISaleConditions conditions
    ) external {}

    /// @inheritdoc IDeposit
    function partialBuyerDepositToLockAsset(uint256 amount, address currency)
        external
    {}

    /// @inheritdoc IDeposit
    function wholeDeposit(
        AssetNft asset,
        IAssetOfferApproval approval,
        ISaleConditions conditions
    ) external {}

    /// @inheritdoc IDeposit
    function depositState(
        AssetNft asset,
        IAssetOfferApproval approval,
        ISaleConditions conditions
    ) external view returns (DepositState memory) {}
}
