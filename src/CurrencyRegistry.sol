// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/**
 * @notice Save & update supported ERC20 as currency for exchange in the MArketplace.
 */
contract CurrencyRegistry is Ownable {
    event CurrencyAdded(address currencyAddress, string ticker);
    event CurrenciesAdded(address[] currencyAddress, string[] ticker);

    mapping(string => address) public supportedCurrenciesAddress;
    mapping(address => string) public supportedCurrenciesTicker;

    function addCurrency(address _address, string memory _ticker) public {
        _addCurrency(_address, _ticker);
        emit CurrencyAdded(_address, _ticker);
    }

    function addCurrencies(
        address[] memory _addresses,
        string[] memory _tickers
    ) public {
        require(_addresses.length == _tickers.length, "ARRAY_LENGTH");
        for (uint256 i = 0; i < _addresses.length; i++) {
            _addCurrency(_addresses[i], _tickers[i]);
        }
        emit CurrenciesAdded(_addresses, _tickers);
    }

    function _addCurrency(address _address, string memory _ticker)
        public
        onlyOwner
    {
        require(
            !isCurrencyRegistered(_address, _ticker),
            "CURRENCY_REGISTERED"
        );
        require(_address != address(0), "ADDRESS_ZERO");
        require(bytes(_ticker).length > 0, "MISSING_LABEL");

        supportedCurrenciesAddress[_ticker] = _address;
        supportedCurrenciesTicker[_address] = _ticker;
    }

    function isCurrencyRegistered(address currency, string memory ticker)
        public
        view
        returns (bool)
    {
        return
            bytes(supportedCurrenciesTicker[currency]).length > 0 &&
            supportedCurrenciesAddress[ticker] != address(0);
    }
}
