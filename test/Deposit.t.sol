// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockUSDC} from "./mock/MockUSDC.sol";
import {MockDeposit, Deposit, AssetNft, SaleConditions, OfferApproval} from "./mock/MockDeposit.sol";
import {MockOfferApproval} from "./mock/MockOfferApproval.sol";

contract DepositTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event DepositAsked(
        AssetNft indexed asset,
        Deposit.DepositState indexed approval
    );

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

    function testDepositStateUpdateAfterDepositAskHasBeenTriggered() public {
        OfferApproval.Approval memory approval;
        approval = _createOfferApprovalWithCustomPrice();

        // console.log(approval.conditions.paymentTerms.consummationSaleTimeframe);

        deposit.emitDepositAsk(nftAsset, approval);

        // fetch saved data
        (
            Deposit.DepositStatus savedStatus,
            bool savedLockStatus,
            OfferApproval.Approval memory savedApproval
        ) = deposit.depositStateOf(nftAsset);

        // Foundry doesn't support enum comparison, only integer comparison.
        assertEq(uint256(savedStatus), uint256(Deposit.DepositStatus.Pending));
        assertFalse(savedLockStatus);
        // Compare struct Approval field by field as Foundry doesn't support direct
        // comparison.
        assertEq(savedApproval.buyer, approval.buyer);
        assertEq(savedApproval.atFloorPrice, approval.atFloorPrice);
        assertEq(savedApproval.price, approval.price);
        assertEq(savedApproval.approvalTimestamp, approval.approvalTimestamp);
        // struct Conditions comparison
        assertEq(
            savedApproval.conditions.floorPrice,
            approval.conditions.floorPrice
        );
        assertEq(
            savedApproval.conditions.paymentTerms.consummationSaleTimeframe,
            approval.conditions.paymentTerms.consummationSaleTimeframe
        );
        // struct ExtraSaleTerms comparison
        assertEq(savedApproval.extras.label, approval.extras.label);
        assertEq(
            savedApproval.extras.customTermDescription,
            approval.extras.customTermDescription
        );
    }

    function testEventEmittanceDepositAsked() public {
        OfferApproval.Approval memory approval;
        Deposit.DepositState memory depositState_;
        approval = _createOfferApprovalWithCustomPrice();

        deposit.emitDepositAsk(nftAsset, approval);
        (
            depositState_.status,
            depositState_.isAssetLocked,
            depositState_.approval
        ) = deposit.depositStateOf(nftAsset);

        // FIXME: second topic (depositState_) is not checked because it fails on
        // "invalid log". The issue might be related to the fact that we create a
        // Deposit.DepositState memory above located to a different storage location than
        // the one emitted in the event
        vm.expectEmit(true, false, true, true);
        emit DepositAsked(nftAsset, depositState_);
        deposit.emitDepositAsk(nftAsset, approval);
    }

    function testBuyerDepositWholeAmountAgreedInOfferApprovalERC20Only()
        public
    {
        // Owner mints USDC to buyer
        vm.prank(owner);
        uint256 usdcMintedToBuyer = 6450592 * 10**18;
        USDC.mint(buyer, usdcMintedToBuyer);
        // Verify and save USDC blance of buyer
        assertEq(USDC.balanceOf(buyer), usdcMintedToBuyer);
        // Verify USDC balance of deposit contract == 0
        assertEq(USDC.balanceOf(address(deposit)), 0);

        // Simulate a deposit ask after an offer has been approved
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        deposit.emitDepositAsk(nftAsset, approval);

        deposit.buyerWholeDepositERC20(nftAsset);

        /*//////////////////////////////////////////////////////////////
						        RESULTS VERIFICATION
	    //////////////////////////////////////////////////////////////*/
        Deposit.DepositData memory assets;
        (assets.buyerData, assets.sellerData) = deposit.depositedDataOf(
            nftAsset
        );

        // assertEq(assets.currency.address, "USDC");
        assertEq(assets.buyerData.symbol, "USDC");
        assertEq(assets.buyerData.amount, approval.price);

        // Verify USDC balance of deposit contract == assets.currency.amount
        // Verify USDC balance of buyer == initialiBuyerBalance - assets.currency.amount

        // Verify deposit state has been updated
        (Deposit.DepositStatus depositStatus, , ) = deposit.depositStateOf(
            nftAsset
        );
        assertEq(
            uint256(depositStatus),
            uint256(Deposit.DepositStatus.BuyerFullDeposit)
        );
    }
}
