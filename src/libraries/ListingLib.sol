// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library ListingLib {
    /**
     * @dev Enumarates the different listing statuses depending on
     *      SaleConditions.
     */
    enum Status {
        Unlisted,
        ActiveListing,
        UnlistedByDeposit
    }
}
