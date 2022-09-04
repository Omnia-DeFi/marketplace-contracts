// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {CurrencyRegistry} from "../src/CurrencyRegistry.sol";
import {MockCurrencyRegistry} from "./mock/MockCurrencyRegistry.sol";

contract MockAssetListingTest is Test {
    event CurrencyAdded(address currencyAddress, string ticker);
    event CurrenciesAdded(address[] currencyAddress, string[] ticker);

    MockCurrencyRegistry registry = new MockCurrencyRegistry();
    address immutable alice = 0x065e3DbaFCb2C26A978720f9eB4Bce6aD9D644a1;

    function testAddCurrency() public {
        registry.addCurrency(address(0x12345678), "TEST");

        assertTrue(
            registry.supportedCurrenciesAddress("TEST") == address(0x12345678)
        );
        assertTrue(
            keccak256(
                abi.encodePacked(
                    registry.supportedCurrenciesTicker(address(0x12345678))
                )
            ) == keccak256(abi.encodePacked("TEST"))
        );
    }

    function testEventEmittanceCurencyAdded() public {
        vm.expectEmit(true, true, true, true);
        emit CurrencyAdded(address(0x12345678), "TEST");
        registry.addCurrency(address(0x12345678), "TEST");
    }

    function testAddCurrencies() public {
        address[] memory _addresses = new address[](2);
        string[] memory _tickers = new string[](2);

        _addresses[0] = address(0x12345678);
        _addresses[1] = address(0x15239FEd28);
        _tickers[0] = "ELSE";
        _tickers[1] = "OTHER";

        registry.addCurrencies(_addresses, _tickers);
        // First currency
        assertTrue(
            registry.supportedCurrenciesAddress("ELSE") == address(0x12345678)
        );
        assertTrue(
            keccak256(
                abi.encodePacked(
                    registry.supportedCurrenciesTicker(address(0x12345678))
                )
            ) == keccak256(abi.encodePacked("ELSE"))
        );
        // Second currency
        assertTrue(
            registry.supportedCurrenciesAddress("OTHER") ==
                address(0x15239FEd28)
        );
        assertTrue(
            keccak256(
                abi.encodePacked(
                    registry.supportedCurrenciesTicker(address(0x15239FEd28))
                )
            ) == keccak256(abi.encodePacked("OTHER"))
        );
    }

    function testEventEmittanceCurenciesAdded() public {
        address[] memory _addresses = new address[](2);
        string[] memory _tickers = new string[](2);

        _addresses[0] = address(0x12345678);
        _addresses[1] = address(0x15239FEd28);
        _tickers[0] = "ELSE";
        _tickers[1] = "OTHER";

        vm.expectEmit(true, true, true, true);
        emit CurrenciesAdded(_addresses, _tickers);
        registry.addCurrencies(_addresses, _tickers);
    }

    function testAddCurrenciesFailsOnArrayLength() public {
        // Address array length shorter
        address[] memory _addresses = new address[](1);
        string[] memory _tickers = new string[](2);

        vm.expectRevert("ARRAY_LENGTH");
        registry.addCurrencies(_addresses, _tickers);

        // Ticker array length shorter
        address[] memory _addresses2 = new address[](2);
        string[] memory _tickers2 = new string[](1);

        vm.expectRevert("ARRAY_LENGTH");
        registry.addCurrencies(_addresses2, _tickers2);
    }
}
