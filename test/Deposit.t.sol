// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockDeposit, Deposit, AssetNft, SaleConditions, OfferApproval} from "./mock/MockDeposit.sol";

contract DepositTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    AssetNft public nftAsset;
    MockMarketplace public marketplace;
    MockDeposit public deposit;
    address immutable owner = msg.sender;

    function setUp() public {
        nftAsset = new AssetNft("AssetMocked", "MA1", owner);
        marketplace = new MockMarketplace();
        deposit = new MockDeposit();

        vm.prank(owner);
        nftAsset.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );
    }
}
