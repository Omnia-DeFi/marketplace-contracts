// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @notice Save & update supported ERC20 as currency for exchange in the MArketplace.
 */
contract CurrencyRegistry {
    mapping(string => address) public supportedCurrenciesAddress;
    mapping(address => string) public supportedCurrenciesTicker;

    function addCurrency(address _address, string memory _ticker) public {
        _addCurrency(_address, _ticker);
        // emit event
    }

    function addCurrencies(address[] memory _address, string[] memory _ticker)
        public
    {
        require(_address.length == _ticker.length, "ARRAY_LENGTH");
        for (uint256 i = 0; i < _address.length; i++) {
            _addCurrency(_address[i], _ticker[i]);
        }
        // emit event
    }

    function _addCurrency(address _address, string memory _ticker) public {
        supportedCurrenciesAddress[_ticker] = _address;
        supportedCurrenciesTicker[_address] = _ticker;
    }
}
