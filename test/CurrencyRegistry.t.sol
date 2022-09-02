// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {CurrencyRegistry} from "../src/CurrencyRegistry.sol";
import {MockCurrencyRegistry} from "./mock/MockCurrencyRegistry.sol";

contract MockAssetListingTest is Test {
    event CurrencyAdded(address currencyAddress, string ticker);

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

}
