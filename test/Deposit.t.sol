// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/libraries/ListingLib.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockUSDC} from "./mock/MockUSDC.sol";
import {MockDeposit, Deposit, AssetNft, SaleConditions, OfferApproval} from "./mock/MockDeposit.sol";
import {MockOfferApproval} from "./mock/MockOfferApproval.sol";

import {SaleConditionsCreateFetch} from "./utils/SaleConditionsCreateFetch.sol";
import {OfferApprovalCreateFetch} from "./utils/OfferApprovalCreateFetch.sol";
import {DepositCreateFetch} from "./utils/DepositCreateFetch.sol";

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

    function __createOfferApprovalWithCustomPrice()
        internal
        returns (OfferApproval.Approval memory approval)
    {
        (conditionsSetUp, extrasSetUp) = SaleConditionsCreateFetch
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
        approval = OfferApprovalCreateFetch.approvedOfferOf(
            offerApproval,
            nftAsset
        );
    }

    function _emitDepositAskAfterOfferApprovalAndMintUSDCToBuyer(
        uint256 usdcToBuyer
    ) internal returns (OfferApproval.Approval memory appr) {
        appr = __createOfferApprovalWithCustomPrice();

        // Simulate a deposit ask after an offer has been approved
        deposit.emitDepositAsk(nftAsset, appr);

        // Mints USDC to buyer
        USDC.mint(buyer, usdcToBuyer);
        // USDC balance of deposit contract == 0
        assertEq(USDC.balanceOf(address(deposit)), 0);
    }

    function _buyerDepositAfterDepositEmitted(uint256 usdcToBuyer)
        internal
        returns (OfferApproval.Approval memory appr)
    {
        appr = _emitDepositAskAfterOfferApprovalAndMintUSDCToBuyer(usdcToBuyer);

        // Buyer make deposit
        vm.prank(buyer);
        deposit.buyerWholeDepositERC20(nftAsset, address(USDC), "USDC");
    }

    function _sellerDepositAfterBuyerDeposit(uint256 usdcToBuyer)
        internal
        returns (OfferApproval.Approval memory appr)
    {
        appr = _buyerDepositAfterDepositEmitted(usdcToBuyer);
        // Let seller deposit AssetNft
        vm.prank(owner);
        deposit.sellerDepositAssetNft(nftAsset);
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
            1,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );

        /**
         * For test purposes we will allow deposit contract unlimited transfer access to
         * USDC & AssetNft and no need to test this case as we use OpenZeppelin contracts
         */
        // USDC from buyer
        vm.prank(buyer);
        USDC.approve(address(deposit), 2**256 - 1); // unlimited allowance
        // AssetNft from owner
        vm.prank(owner);
        nftAsset.setApprovalForAll(address(deposit), true); // unlimited allowance
    }

    /*//////////////////////////////////////////////////////////////
                                 DEPOSIT ASK
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Verifies values update after an offer has been approved and the deposit ask
     *      triggered.
     */
    function testDepositStateUpdateAfterDepositAskHasBeenTriggered() public {
        OfferApproval.Approval
            memory approval = _emitDepositAskAfterOfferApprovalAndMintUSDCToBuyer(
                0
            );

        // fetch saved data
        Deposit.DepositData memory saved = DepositCreateFetch.depositedDataOf(
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
            memory approval = _emitDepositAskAfterOfferApprovalAndMintUSDCToBuyer(
                0
            );

        Deposit.DepositData memory saved = DepositCreateFetch.depositedDataOf(
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
    /// @dev Verifies only approved buyer can make a deposit.
    function testBuyerWholeDepositBuyerNotApproved() public {
        // Simulate a deposit ask after an offer has been approved
        OfferApproval.Approval
            memory approval = _emitDepositAskAfterOfferApprovalAndMintUSDCToBuyer(
                0
            );

        vm.startPrank(randomWallet);
        // Deposit fails as `randomWallet` is not approved, only `buyer` is & fails before
        // ERC20 balance issue
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
        uint256 usdcMintedToBuyer = 6450592 * 10**18;
        OfferApproval.Approval
            memory approval = _buyerDepositAfterDepositEmitted(
                usdcMintedToBuyer
            );

        // Verify DepositData update
        Deposit.DepositData memory saved = DepositCreateFetch.depositedDataOf(
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
        // Simulate a deposit ask after an offer has been approved
        OfferApproval.Approval
            memory approval = _emitDepositAskAfterOfferApprovalAndMintUSDCToBuyer(
                6450592 * 10**18
            );

        Deposit.DepositData memory depositData = DepositCreateFetch
            .createDepositData(approval, address(USDC), "USDC", false, 0);

        // Buyer makes the deposit
        vm.prank(buyer);
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
        OfferApproval.Approval
            memory approval = _sellerDepositAfterBuyerDeposit(
                325249033 * 10**18
            );

        // Deposit contract should have all AssetNft
        assertEq(nftAsset.balanceOf(address(deposit), 0), 1);

        // Verify DepositData update
        Deposit.DepositData memory saved = DepositCreateFetch.depositedDataOf(
            deposit,
            nftAsset
        );
        // SellerData
        assertTrue(saved.sellerData.hasSellerDepositedAll);
        assertEq(saved.sellerData.amount, 1);
        // DepositState
        assertEq(
            uint256(saved.state.status),
            uint256(Deposit.DepositStatus.AllDepositMade)
        );
    }

    function testEventEmittanceSellerDeposit() public {
        OfferApproval.Approval
            memory approval = _buyerDepositAfterDepositEmitted(
                325249033 * 10**18
            );

        // Configuring DepositDat struct that should be emitted later
        Deposit.DepositData memory depositData = DepositCreateFetch
            .createDepositData(approval, address(USDC), "USDC", true, 1);

        //vCheck event emittance
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit SellerDeposit(nftAsset, depositData, block.timestamp);
        deposit.sellerDepositAssetNft(nftAsset);
    }

    /// @dev Swap assets fails on MISSING_DEPOSIT
    function testAllDepositMadeToTriggerSwap() public {
        vm.prank(owner);
        vm.expectRevert("MISSING_DEPOSIT");
        deposit.swapAssets(nftAsset);
    }

    function testSwapAssets() public {
        OfferApproval.Approval
            memory approval = _sellerDepositAfterBuyerDeposit(
                325249033 * 10**18
            );

        // Swap logic
        uint256 previousOwnerUSDC = USDC.balanceOf(owner);
        deposit.swapAssets(nftAsset);

        ////////// Verify values //////////
        // Deposit contract doesn't have any AssetNft anymore
        assertEq(nftAsset.balanceOf(address(deposit), 0), 0);
        // buyer received AssetNft
        assertEq(nftAsset.balanceOf(buyer, 0), 1);
        // Deposit contract doesn't have any USDC anymore
        assertEq(USDC.balanceOf(address(deposit)), 0);
        // Seller received the deposited USDC for the price agreeed
        assertEq(USDC.balanceOf(owner), previousOwnerUSDC + approval.price);
    }

    //TODO: test _resetDepositData & DepositDataReset event emittance
}
