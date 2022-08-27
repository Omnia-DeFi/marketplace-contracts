// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {AssetNft, MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockOfferApproval, SaleConditions} from "./mock/MockOfferApproval.sol";

contract MockAssetListingTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AssetListed(AssetNft indexed asset, ListingLib.Status indexed status);

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    AssetNft public nftAsset;
    MockMarketplace public marketplace;
    MockOfferApproval public approval;
    address immutable owner = msg.sender;

    function setUp() public {
        nftAsset = new AssetNft("AssetMocked", "MA1", owner);
        marketplace = new MockMarketplace();
        approval = new MockOfferApproval();

        vm.prank(owner);
        nftAsset.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );
    }

    function testOnlyOwnerCanApproveAnOffer() external {}
}
