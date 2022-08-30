// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/Marketplace.sol";
import "../src/AssetListing.sol";
import "../src/SaleConditions.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";

contract MarketplaceTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AssetListedForSale(
        AssetNft assetNft,
        uint256 assetId,
        uint256 floorPrice
    );

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    address immutable owner = 0xbB0007bc73E7e683537A17e46b8100EAd6a8c577;
    address immutable alice = 0x065e3DbaFCb2C26A978720f9eB4Bce6aD9D644a1;
    address immutable bob = 0x7F101fE45e6649A6fB8F3F8B43ed03D353f2B90c;
    address immutable conveyancer = 0xab3B229eB4BcFF881275E7EA2F0FD24eeaC8C83a;
    address immutable solicitor = 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8;
    address immutable omnia = 0x1aD91ee08f21bE3dE0BA2ba6918E714dA6B45836;

    /*//////////////////////////////////////////////////////////////
                                 ASSET
    //////////////////////////////////////////////////////////////*/
    AssetNft public assetNft;

    Marketplace marketplace;
    SaleConditions.Conditions conditionsSetUp;
    SaleConditions.ExtraSaleTerms extrasSetUp;

    /*//////////////////////////////////////////////////////////////
                            SET UP TEST DATA
    //////////////////////////////////////////////////////////////*/
    function createBaseSaleConditions() public {
        conditionsSetUp.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        conditionsSetUp.paymentTerms.consummationSaleTimeframe = 24 hours;
    }

    function setUp() public {
        marketplace = new Marketplace();
        assetNft = new AssetNft("AssetMocked", "MA1", owner);

        vm.prank(owner);
        assetNft.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );

        createBaseSaleConditions();
    }

    /*//////////////////////////////////////////////////////////////
                            LIST ASSET FOR SALE
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Seller list their asset for sale with a floor price in USD.
     * @dev In the frontend the price will have to be multiplied by 10**2 as blockchains
     *      don't deal with decimals.
     */
    function testOnlySellerCanListAnAssetAndSetSaleConditions() external {
        vm.expectRevert("NOT_OWNER");
        marketplace.listAssetWithSaleConditions(
            assetNft,
            conditionsSetUp,
            extrasSetUp
        );

        vm.startPrank(owner);
        marketplace.listAssetWithSaleConditions(
            assetNft,
            conditionsSetUp,
            extrasSetUp
        );
    }

    function testApproveSaleAtFloorPriceOnlyIfAssetListed() public {
        vm.expectRevert("ASSET_NOT_LISTED");
        marketplace.approveSale(assetNft, alice, conditionsSetUp, extrasSetUp);
    }
}
