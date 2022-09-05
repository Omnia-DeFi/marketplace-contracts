// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockSaleConditions, SaleConditions} from "./mock/MockSaleConditions.sol";
import {SaleConditions} from "../src/SaleConditions.sol";

import {CreateFetchSaleConditions} from "./utils/CreateFetchSaleConditions.sol";

contract MockSaleConditionsTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event SaleConditionsSet(
        AssetNft indexed asset,
        SaleConditions.Conditions indexed conditions,
        SaleConditions.ExtraSaleTerms indexed extras
    );

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    MockMarketplace public marketplace;
    MockSaleConditions public saleConditions;
    AssetNft asset;
    address immutable owner = msg.sender;

    function setUp() public {
        marketplace = new MockMarketplace();
        asset = new AssetNft("AssetMocked", "MA1", owner);
        saleConditions = new MockSaleConditions();

        vm.prank(owner);
        asset.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );
    }

    function testOnlyAssetOwnerCanSetSaleConditions() external {
        (
            SaleConditions.Conditions memory conditions_,
            SaleConditions.ExtraSaleTerms memory extras_
        ) = CreateFetchSaleConditions.createdDefaultSaleConditions();
        // Verify revert
        vm.expectRevert("NOT_OWNER");
        saleConditions.setSaleConditions(asset, conditions_, extras_);
        // Verify success
        vm.prank(owner);
        saleConditions.setSaleConditions(asset, conditions_, extras_);
    }

    function testSetSaleConditionsFailsOnSaleConditionsFormatModifier()
        external
    {
        vm.startPrank(owner);

        SaleConditions.Conditions memory conditions_;
        SaleConditions.ExtraSaleTerms memory extras_;
        // No floor price
        vm.expectRevert(abi.encodePacked("ZERO_FLOOR_PRICE"));
        saleConditions.setSaleConditions(asset, conditions_, extras_);
        // Floor price set but not the consummation timeframe of the sale
        conditions_.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        vm.expectRevert(abi.encodePacked("MIN_24H_SALE"));
        saleConditions.setSaleConditions(asset, conditions_, extras_);
    }

    function testSetSaleConditionsFailsOnExtraTermsFormatModifier() external {
        vm.startPrank(owner);

        (
            SaleConditions.Conditions memory conditions_,

        ) = CreateFetchSaleConditions.createdDefaultSaleConditions();
        SaleConditions.ExtraSaleTerms memory extras_;

        // Label of extra terms too short, at least 4 characters required
        extras_.label = "333";
        vm.expectRevert(abi.encodePacked("4_CHAR_LABEL"));
        saleConditions.setSaleConditions(asset, conditions_, extras_);
        //  too short, at least 4 characters required
        extras_.label = "RandomLabel";
        extras_.customTermDescription = "sho";
        vm.expectRevert(abi.encodePacked("4_CHAR_TERM"));
        saleConditions.setSaleConditions(asset, conditions_, extras_);
    }

    function testSetSaleConditionsFailsOnExistingSaleConditions() external {
        vm.startPrank(owner);

        (
            SaleConditions.Conditions memory conditions_,
            SaleConditions.ExtraSaleTerms memory extras_
        ) = CreateFetchSaleConditions.createdDefaultSaleConditions();
        // Set conditions a first, to trigger the revert below
        saleConditions.setSaleConditions(asset, conditions_, extras_);

        vm.expectRevert(abi.encodePacked("MIN_CONDITIONS_SET"));
        saleConditions.setSaleConditions(asset, conditions_, extras_);
    }

    function testEventEmittanceSaleConditionsSet() external {
        vm.startPrank(owner);

        (
            SaleConditions.Conditions memory conditions_,
            SaleConditions.ExtraSaleTerms memory extras_
        ) = CreateFetchSaleConditions.createdDefaultSaleConditions();

        vm.expectEmit(true, true, true, true);
        emit SaleConditionsSet(asset, conditions_, extras_);
        saleConditions.setSaleConditions(asset, conditions_, extras_);
    }

    function testVerifySaleConditionsSavingValues() external {
        vm.startPrank(owner);

        (
            SaleConditions.Conditions memory conditions_,
            SaleConditions.ExtraSaleTerms memory extras_
        ) = CreateFetchSaleConditions.createdDefaultSaleConditions();
        // Set conditions a first, to trigger the revert below
        saleConditions.setSaleConditions(asset, conditions_, extras_);

        // fetch saved SaleConditions
        (
            SaleConditions.Conditions memory savedConditions,
            SaleConditions.ExtraSaleTerms memory savedExtras
        ) = CreateFetchSaleConditions.fetchSaleConditionsOf(
                saleConditions,
                asset
            );
        // Conditions
        assertEq(savedConditions.floorPrice, conditions_.floorPrice);
        assertEq(
            savedConditions.paymentTerms.consummationSaleTimeframe,
            conditions_.paymentTerms.consummationSaleTimeframe
        );
        // Extras
        assertEq(savedExtras.label, extras_.label);
        assertEq(
            savedExtras.customTermDescription,
            extras_.customTermDescription
        );
    }

    //TODO: test _resetSaleConditions & SaleConditionsReset event emittance
}
