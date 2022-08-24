// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MockMarketplace, SaleConditions} from "./mock/MockMarketplace.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {ISaleConditions} from "../src/interfaces/ISaleConditions.sol";

contract SaleConditionsTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    MockMarketplace public marketplace;
    AssetNft asset;
    SaleConditions public conditions;
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
        conditions = marketplace.saleConditions();
    }

    function testOnlyAssetOwnerCanSetSaleConditions() external {}

    function testSetSaleConditionsFailsOnSaleConditionsFormatModifier()
        external
    {
        ISaleConditions.Conditions memory conditions_;
        ISaleConditions.ExtraSaleTerms memory extras_;
        // No floor price
        vm.expectRevert(abi.encodePacked("ZERO_FLOOR_PRICE"));
        conditions.setSaleConditions(asset, conditions_, extras_);
        // Floor price set but not the consummation timeframe of the sale
        conditions_.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        vm.expectRevert(abi.encodePacked("MIN_24H_SALE"));
        conditions.setSaleConditions(asset, conditions_, extras_);
    }

    function testSetSaleConditionsFailsOnExtraTermsFormatModifier() external {
        AssetNft asset = new AssetNft("AssetMocked", "MA1", owner);
        (
            ISaleConditions.Conditions memory conditions_,

        ) = returnCreatedSaleConditions();
        ISaleConditions.ExtraSaleTerms memory extras_;

        // Label of extra terms too short, at least 4 characters required
        extras_.label = "333";
        vm.expectRevert(abi.encodePacked("4_CHAR_LABEL"));
        conditions.setSaleConditions(asset, conditions_, extras_);
        //  too short, at least 4 characters required
        extras_.label = "RandomLabel";
        extras_.customTermDescription = "sho";
        vm.expectRevert(abi.encodePacked("4_CHAR_TERM"));
        conditions.setSaleConditions(asset, conditions_, extras_);
    }

    function testSetSaleConditionsFailsOnExistingSaleConditions() external {
        AssetNft asset = new AssetNft("Other", "New", owner);
        (
            ISaleConditions.Conditions memory conditions_,
            ISaleConditions.ExtraSaleTerms memory extras_
        ) = returnCreatedSaleConditions();

        vm.expectRevert(abi.encodePacked("MIN_CONDITIONS_SET"));
        conditions.setSaleConditions(asset, conditions_, extras_);
    }
}
