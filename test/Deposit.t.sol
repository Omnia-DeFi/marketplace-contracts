// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockUSDC} from "./mock/MockUSDC.sol";
import {MockDeposit, Deposit, AssetNft, SaleConditions, OfferApproval} from "./mock/MockDeposit.sol";
import {MockOfferApproval} from "./mock/MockOfferApproval.sol";

import {CreateFetchSaleConditions} from "./utils/CreateFetchSaleConditions.sol";
import {FetchOfferApproval} from "./utils/FetchOfferApproval.sol";
import {CreateFetchDeposit} from "./utils/CreateFetchDeposit.sol";

contract DepositTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event DepositAsked(
        AssetNft indexed asset,
        Deposit.ApprovalResume indexed approval
    );
    event BuyerDeposit(
        AssetNft indexed asset,
        Deposit.DepositData indexed data,
        uint256 depositTime
    );
    event SellerDeposit(
        AssetNft indexed asset,
        Deposit.DepositData indexed data,
        uint256 depositTime
    );

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    AssetNft public nftAsset;
    MockMarketplace public marketplace;
    MockUSDC public immutable USDC = new MockUSDC();
    MockDeposit public deposit;
    MockOfferApproval public offerApproval;
    SaleConditions.Conditions public conditionsSetUp;
    SaleConditions.ExtraSaleTerms public extrasSetUp;

    address immutable owner = msg.sender;
    address buyer = 0x065e3DbaFCb2C26A978720f9eB4Bce6aD9D644a1;
    address randomWallet = 0x5DcB78343780E1B1e578ae0590dc1e868792a435;

    function _createOfferApprovalWithCustomPrice()
        internal
        returns (OfferApproval.Approval memory approval)
    {
        (conditionsSetUp, extrasSetUp) = CreateFetchSaleConditions
            .createdDefaultSaleConditions();

        vm.prank(owner);
        offerApproval.approveSaleOfAtCustomPrice(
            nftAsset,
            buyer,
            324015 * 100,
            conditionsSetUp,
            extrasSetUp
        );
        // fetch saved offer approval
        approval = FetchOfferApproval.approvedOfferOf(offerApproval, nftAsset);
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

    /*//////////////////////////////////////////////////////////////
                                 DEPOSIT ASK
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Verifies values update after an offer has been approved and the deposit ask
     *      triggered.
     */
    function testDepositStateUpdateAfterDepositAskHasBeenTriggered() public {
        OfferApproval.Approval memory approval;
        approval = _createOfferApprovalWithCustomPrice();
        deposit.emitDepositAsk(nftAsset, approval);

        // fetch saved data
        Deposit.DepositData memory saved = CreateFetchDeposit.depositedDataOf(
            deposit,
            nftAsset
        );
        // DepositState
        assertEq(
            uint256(saved.state.status),
            uint256(Deposit.DepositStatus.Pending)
        );
        assertFalse(saved.state.isAssetLocked);
        // SellerData
        assertEq(saved.approval.seller, approval.seller);
        assertEq(saved.approval.buyer, approval.buyer);
        assertEq(saved.approval.price, approval.price);
    }

    /// @dev Verifies emittance of DepositAsked event.
    function testEventEmittanceDepositAsked() public {
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        deposit.emitDepositAsk(nftAsset, approval);

        Deposit.DepositData memory saved = CreateFetchDeposit.depositedDataOf(
            deposit,
            nftAsset
        );

        vm.expectEmit(true, true, true, true);
        emit DepositAsked(nftAsset, saved.approval);
        deposit.emitDepositAsk(nftAsset, approval);
    }

    /*//////////////////////////////////////////////////////////////
                                 DEPOSIT FROM BUYER
    //////////////////////////////////////////////////////////////*/
    function testOnlyApprovedBuyerCanMakeDeposit() public {
        USDC.mint(randomWallet, 6450592 * 10**18);
        // Simulate a deposit ask after an offer has been approved
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        deposit.emitDepositAsk(nftAsset, approval);

        vm.startPrank(randomWallet);

        // Seller approves the deposit
        USDC.approve(address(deposit), approval.price);

        // Deposit fails as `randomWallet` is not approved, only `buyer` is
        vm.expectRevert("BUYER_NOT_APPROVED");
        deposit.buyerWholeDepositERC20(nftAsset, address(USDC), "USDC");
    }

    /**
     * @dev Buyer makes the full deposit in ERC20 and verifies balances & other values
     *      update.
     */
    function testBuyerDepositWholeAmountAgreedInOfferApprovalERC20OnlyAndVerifySavedValues()
        public
    {
        // Mints USDC to buyer
        uint256 usdcMintedToBuyer = 6450592 * 10**18;
        USDC.mint(buyer, usdcMintedToBuyer);
        // USDC balance of deposit contract == 0
        assertEq(USDC.balanceOf(address(deposit)), 0);

        // Simulate a deposit ask after an offer has been approved
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        deposit.emitDepositAsk(nftAsset, approval);

        //////////////// BUYER ACTIONS ////////////////
        vm.startPrank(buyer);
        // Seller approves the deposit
        USDC.approve(address(deposit), approval.price);
        // Seller deposits USDC
        deposit.buyerWholeDepositERC20(nftAsset, address(USDC), "USDC");
        vm.stopPrank();

        //////////////// RESULTS VERIFICATION ////////////////
        Deposit.DepositData memory saved = CreateFetchDeposit.depositedDataOf(
            deposit,
            nftAsset
        );
        // BuyerData
        assertEq(saved.buyerData.currencyAddress, address(USDC));
        assertEq(saved.buyerData.symbol, "USDC");
        assertEq(saved.buyerData.amount, approval.price);
        // USDC balance of deposit contract == assets.buyerData.amount
        assertEq(USDC.balanceOf(address(deposit)), approval.price);
        // USDC balance of buyer == initialiBuyerBalance - assets.buyerData.amount
        assertEq(USDC.balanceOf(buyer), usdcMintedToBuyer - approval.price);
        // DepositState
        assertEq(
            uint256(saved.state.status),
            uint256(Deposit.DepositStatus.BuyerFullDeposit)
        );
        assertTrue(saved.state.isAssetLocked);
    }

    /// @dev Verifies emittance of BuyerDeposit event.
    function testEventEmittanceBuyerDeposit() public {
        USDC.mint(buyer, 6450592 * 10**18);
        // Simulate a deposit ask after an offer has been approved
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        deposit.emitDepositAsk(nftAsset, approval);

        Deposit.DepositData memory depositData = CreateFetchDeposit
            .createDepositData(approval, address(USDC), "USDC", false, 0);

        // Buyer makes the deposit
        vm.startPrank(buyer);
        // approve deposit contract
        USDC.approve(address(deposit), approval.price);
        vm.expectEmit(true, true, true, true);
        emit BuyerDeposit(nftAsset, depositData, block.timestamp);
        deposit.buyerWholeDepositERC20(nftAsset, address(USDC), "USDC");
    }

    /*//////////////////////////////////////////////////////////////
                                 DEPOSIT FROM SELLER
    //////////////////////////////////////////////////////////////*/
    /// @dev Verifies seller can only deposit AssetNft after the buyer has deposited ERC20
    function tesBuyerDepositFirst() public {
        vm.startPrank(owner);

        vm.expectRevert("BUYER_DEPOSIT_FIRST");
        deposit.sellerDepositAssetNft(nftAsset);
    }

    function testSellerDepositAllAssetNftsAndVerifySavedValues() public {
        // Simulate deposit ask
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        vm.prank(owner);
        deposit.emitDepositAsk(nftAsset, approval);
        //////////////// Let buyer deposit USDC ////////////////
        USDC.mint(buyer, 325249033 * 10**18);
        vm.startPrank(buyer);
        // Seller approves the deposit
        USDC.approve(address(deposit), approval.price);
        // Seller deposits USDC
        deposit.buyerWholeDepositERC20(nftAsset, address(USDC), "USDC");
        vm.stopPrank();

        //////////////// Let seller deposit AssetNft ////////////////
        vm.startPrank(owner);
        nftAsset.approve(address(deposit), 0);
        deposit.sellerDepositAssetNft(nftAsset);
        // Deposit contract should have all AssetNft
        assertEq(nftAsset.balanceOf(address(deposit)), 1);

        // Verify DepositData update
        Deposit.DepositData memory saved = CreateFetchDeposit.depositedDataOf(
            deposit,
            nftAsset
        );
        // verifies seller data
        assertTrue(saved.sellerData.hasSellerDepositedAll);
        assertEq(saved.sellerData.amount, 1);
        // Verify DepositState update;
        assertEq(
            uint256(saved.state.status),
            uint256(Deposit.DepositStatus.AllDepositMade)
        );
    }

    function testEventEmittanceSellerDeposit() public {
        //////////////// Deposit logic ////////////////
        // Simulate deposit ask
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        vm.prank(owner);
        deposit.emitDepositAsk(nftAsset, approval);
        // Let buyer deposit USDC
        USDC.mint(buyer, 325249033 * 10**18);
        vm.startPrank(buyer);
        // Seller approves the deposit
        USDC.approve(address(deposit), approval.price);
        // Seller deposits USDC
        deposit.buyerWholeDepositERC20(nftAsset, address(USDC), "USDC");
        vm.stopPrank();

        // Let seller deposit AssetNft
        vm.startPrank(owner);
        nftAsset.approve(address(deposit), 0);
        //////////////// Configuring structs ////////////////
        Deposit.DepositData memory depositData = CreateFetchDeposit
            .createDepositData(approval, address(USDC), "USDC", true, 1);

        //////////////// Check event emittance ////////////////
        vm.expectEmit(true, true, true, true);
        emit SellerDeposit(nftAsset, depositData, block.timestamp);
        deposit.sellerDepositAssetNft(nftAsset);
    }

    // Swap assets fails on MISSING_DEPOSIT
    function testAllDepositMadeToTriggerSwap() public {
        vm.prank(owner);
        vm.expectRevert("MISSING_DEPOSIT");
        deposit.swapAssets(nftAsset);
    }

    function testSwapAssets() public {
        //////////////// Deposit logic ////////////////
        // Simulate deposit ask
        OfferApproval.Approval
            memory approval = _createOfferApprovalWithCustomPrice();
        vm.prank(owner);
        deposit.emitDepositAsk(nftAsset, approval);
        // Let buyer deposit USDC
        USDC.mint(buyer, 325249033 * 10**18);
        vm.startPrank(buyer);
        // Seller approves the deposit
        USDC.approve(address(deposit), approval.price);
        // Seller deposits USDC
        deposit.buyerWholeDepositERC20(nftAsset, address(USDC), "USDC");
        vm.stopPrank();
        // Let seller deposit AssetNft
        vm.startPrank(owner);
        nftAsset.approve(address(deposit), 0);
        deposit.sellerDepositAssetNft(nftAsset);

        //////////////// Swap logic ////////////////
        uint256 previousOwnerUSDC = USDC.balanceOf(owner);

        deposit.swapAssets(nftAsset);

        // Deposit contract doesn't have any AssetNft anymore
        assertEq(nftAsset.balanceOf(address(deposit)), 0);
        // buyer received AssetNft
        assertEq(nftAsset.balanceOf(buyer), 1);
        // Deposit contract doesn't have any USDC anymore
        assertEq(USDC.balanceOf(address(deposit)), 0);
        // Seller received the deposited USDC for the price agreeed
        assertEq(USDC.balanceOf(owner), previousOwnerUSDC + approval.price);
    }

    //TODO: test _resetDepositData & DepositDataReset event emittance
}
