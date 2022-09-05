// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {MockMarketplace, Marketplace} from "./MockMarketplace.sol";

contract MockMarketplaceWithCurrency is MockMarketplace {
    constructor(address mockAddr, string memory mockLabel) {
        addCurrency(mockAddr, mockLabel);
    }
}
