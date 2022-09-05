// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {CurrencyRegistry} from "../../src/CurrencyRegistry.sol";

contract MockCurrencyRegistry is CurrencyRegistry {
    function mockInternalAddCurrency(address _address, string memory _ticker)
        public
    {
        _addCurrency(_address, _ticker);
    }
}
