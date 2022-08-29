// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockUSDC} from "./mock/MockUSDC.sol";
import {MockDeposit, Deposit, AssetNft, SaleConditions, OfferApproval} from "./mock/MockDeposit.sol";
import {MockOfferApproval} from "./mock/MockOfferApproval.sol";
import {MockSaleConsummation} from "./mock/MockSaleConsummation.sol";

contract DepositTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    AssetNft public nftAsset;
    MockMarketplace public marketplace;
    MockUSDC public immutable USDC = new MockUSDC();
    MockDeposit public deposit;
    MockOfferApproval public offerApproval;

    address immutable owner = msg.sender;
    address buyer = 0x065e3DbaFCb2C26A978720f9eB4Bce6aD9D644a1;
    address randomWallet = 0x5DcB78343780E1B1e578ae0590dc1e868792a435;

    function _createOfferApprovalWithCustomPrice()
        internal
        returns (OfferApproval.Approval memory)
    {
        vm.startPrank(owner);
        uint256 customPrice = 324015 * 100;
        uint256 timestamp = block.timestamp;

        SaleConditions.Conditions memory conditionsSetUp;
        SaleConditions.ExtraSaleTerms memory extrasSetUp;
        OfferApproval.Approval memory approval;

        conditionsSetUp.floorPrice = 650000 * marketplace.FIAT_PRICE_DECIMAL();
        conditionsSetUp.paymentTerms.consummationSaleTimeframe = 24 hours;

        offerApproval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            customPrice,
            conditionsSetUp,
            extrasSetUp
        );

        // fetch saved offer approval
        (
            approval.buyer,
            approval.atFloorPrice,
            approval.price,
            approval.approvalTimestamp,
            approval.conditions,
            approval.extras,
            approval.ownerSignature
        ) = offerApproval.approvedOfferOf(nftAsset);

        vm.stopPrank();

        return approval;
    }

    function setUp() public {
        nftAsset = new AssetNft("AssetMocked", "MA1", owner);
        marketplace = new MockMarketplace();
        deposit = new MockDeposit();
        offerApproval = new MockOfferApproval();

        vm.prank(owner);
        nftAsset.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );
    }

    function _mintUSDCTo(address to, uint256 amount) internal {
        // Owner mints USDC to buyer
        vm.prank(owner);
        USDC.mint(to, amount);
    }

    // Verify mint function once and for all
    function testMintUSDTo() public {
        _mintUSDCTo(buyer, 100);
        assertEq(USDC.balanceOf(buyer), 100);
    }
}
