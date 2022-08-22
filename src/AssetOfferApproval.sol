// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {IAssetOfferApproval, ISaleConditions} from "./interfaces/IAssetOfferApproval.sol";

/**
 * @notice Contract that allows a seller to approve a buy request that
 *         was placed off-chain by a specific buyer.
 *         Approving a sale request will lead to a deposit triggered by
 *         the Marketplace.
 */
contract AssetOfferApproval is IAssetOfferApproval {
    /// @inheritdoc IAssetOfferApproval
    function approveSaleOfAtFloorPrice(
        address asset,
        address buyer,
        ISaleConditions conditions
    ) external {}

    /// @inheritdoc IAssetOfferApproval
    function approveSaleOfAtCustomPrice(
        address asset,
        address buyer,
        uint256 salePrice,
        ISaleConditions conditions
    ) external {}
}
