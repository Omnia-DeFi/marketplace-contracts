// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {ISaleConditions} from "./ISaleConditions.sol";
import {IDeposit} from "./IDeposit.sol";

interface ISaleConsummation {
    event SaleConsummated(
        address indexed asset,
        address indexed buyer,
        ISaleConditions indexed conditions,
        IDeposit deposit
    );

    /**
     * @notice Consummate the sale of the asset to trigger the swap of
     *         assets deposited into the Deposit contract.
     *
     * @param asset The asset to be consummated.
     * @param buyer The buyer of the asset.
     * @param conditions The sale conditions of the asset.
     * @param deposit The deposit contractcontaing the currency and the
     *                NFTs.
     *
     * @return Sale consummation success or failure.
     */
    function consummateSale(
        address asset,
        address buyer,
        ISaleConditions conditions,
        IDeposit deposit
    ) external returns (bool);
}
