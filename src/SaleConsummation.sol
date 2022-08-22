// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {ISaleConsummation, ISaleConditions, IDeposit} from "./interfaces/ISaleConsummation.sol";

/**
 * @notice Once all sale conditions are met, the sale of the asset is
 *         consummated and the swap is instantly made. Each side can
 *         then claim their respective assets.
 */
contract SaleConsummation is ISaleConsummation {
    /// @inheritdoc ISaleConsummation
    function consummateSale(
        address asset,
        address buyer,
        ISaleConditions conditions,
        IDeposit deposit
    ) external returns (bool) {}
}
