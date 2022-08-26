// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockSaleConditions, SaleConditions} from "./mock/MockSaleConditions.sol";
import {ISaleConditions} from "../src/interfaces/ISaleConditions.sol";

contract MockSaleConditionsTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event SaleConditionsSet(
        AssetNft indexed asset,
        ISaleConditions.Conditions indexed conditions,
        ISaleConditions.ExtraSaleTerms extras
    );

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    MockMarketplace public marketplace;
    AssetNft asset;
    address immutable owner = msg.sender;

    function returnCreatedSaleConditions()
        public
        returns (
            ISaleConditions.Conditions memory conditions,
            ISaleConditions.ExtraSaleTerms memory extras
        )
    {
        conditions.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        conditions.paymentTerms.consummationSaleTimeframe = 24 hours;

        extras.label = "RandomLabel";
        extras.customTermDescription = "short";
    }

    function setUp() public {
        marketplace = new MockMarketplace();
        asset = new AssetNft("AssetMocked", "MA1", owner);

        vm.prank(owner);
        asset.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );
    }

    function testOnlyAssetOwnerCanSetSaleConditions() external {}

    function testSetSaleConditionsFailsOnSaleConditionsFormatModifier()
        external
    {
        vm.startPrank(owner);

        ISaleConditions.Conditions memory conditions_;
        ISaleConditions.ExtraSaleTerms memory extras_;
        // No floor price
        vm.expectRevert(abi.encodePacked("ZERO_FLOOR_PRICE"));
        marketplace.setSaleConditions(asset, conditions_, extras_);
        // Floor price set but not the consummation timeframe of the sale
        conditions_.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        vm.expectRevert(abi.encodePacked("MIN_24H_SALE"));
        marketplace.setSaleConditions(asset, conditions_, extras_);
    }

    function testSetSaleConditionsFailsOnExtraTermsFormatModifier() external {
        vm.startPrank(owner);

        (
            ISaleConditions.Conditions memory conditions_,

        ) = returnCreatedSaleConditions();
        ISaleConditions.ExtraSaleTerms memory extras_;

        // Label of extra terms too short, at least 4 characters required
        extras_.label = "333";
        vm.expectRevert(abi.encodePacked("4_CHAR_LABEL"));
        marketplace.setSaleConditions(asset, conditions_, extras_);
        //  too short, at least 4 characters required
        extras_.label = "RandomLabel";
        extras_.customTermDescription = "sho";
        vm.expectRevert(abi.encodePacked("4_CHAR_TERM"));
        marketplace.setSaleConditions(asset, conditions_, extras_);
    }

    function testSetSaleConditionsFailsOnExistingSaleConditions() external {
        vm.startPrank(owner);

        (
            ISaleConditions.Conditions memory conditions_,
            ISaleConditions.ExtraSaleTerms memory extras_
        ) = returnCreatedSaleConditions();
        // Set conditions a first, to trigger the revert below
        marketplace.setSaleConditions(asset, conditions_, extras_);

        vm.expectRevert(abi.encodePacked("MIN_CONDITIONS_SET"));
        marketplace.setSaleConditions(asset, conditions_, extras_);
    }

    function testEventEmittanceSaleConditionsSet() external {
        vm.startPrank(owner);

        (
            ISaleConditions.Conditions memory conditions_,
            ISaleConditions.ExtraSaleTerms memory extras_
        ) = returnCreatedSaleConditions();

        vm.expectEmit(true, true, true, true);
        emit SaleConditionsSet(asset, conditions_, extras_);
        marketplace.setSaleConditions(asset, conditions_, extras_);
    }

    function testVerifySaleConditionsSavingValues() external {
        vm.startPrank(owner);

        (
            ISaleConditions.Conditions memory conditions_,
            ISaleConditions.ExtraSaleTerms memory extras_
        ) = returnCreatedSaleConditions();
        // Set conditions a first, to trigger the revert below
        marketplace.setSaleConditions(asset, conditions_, extras_);

        // Conditions
        (
            uint256 savedFloorPrice,
            ISaleConditions.PaymentTerms memory paymentTerms
        ) = marketplace.saleConditionsOf(asset);
        assertEq(savedFloorPrice, conditions_.floorPrice);
        assertEq(
            paymentTerms.consummationSaleTimeframe,
            conditions_.paymentTerms.consummationSaleTimeframe
        );
        //Extra terms
        (
            string memory savedLabel,
            string memory savedeTermDescription
        ) = marketplace.extraSaleConditionsOf(asset);
        assertEq(savedLabel, extras_.label);
        assertEq(savedeTermDescription, extras_.customTermDescription);
    }
}
