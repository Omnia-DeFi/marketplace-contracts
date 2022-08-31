// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {AssetNft, ListingLib, AssetListing, SaleConditions, OfferApproval, Deposit} from "../src/Marketplace.sol";
import {MockAssetNft} from "./mock/MockAssetNftMintOnDeployment.sol";
import {MockMarketplace} from "./mock/MockMarketplace.sol";
import {MockDeposit} from "./mock/MockDeposit.sol";
import {MockUSDC, IERC20} from "./mock/MockUSDC.sol";
// utils
import {NoEmptyValueTest} from "./utils/NoEmptyValueTest.sol";
import {EmptyValueTest} from "./utils/EmptyValueTest.sol";

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

    MockMarketplace marketplace;
    MockUSDC public immutable USDC = new MockUSDC();
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
        marketplace = new MockMarketplace();
        assetNft = new AssetNft("AssetMocked", "MA1", owner);

        vm.prank(owner);
        assetNft.safeMint(
            owner,
            0,
            "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV"
        );

        createBaseSaleConditions();
    }

    function _mintUSDCTo(address to, uint256 amount) internal {
        // Owner mints USDC to buyer
        vm.prank(owner);
        USDC.mint(to, amount);
    }

    function _listAssetWithConditions()
        internal
        returns (
            ListingLib.Status,
            SaleConditions.Conditions memory mConditions,
            SaleConditions.ExtraSaleTerms memory mExtras
        )
    {
        vm.startPrank(owner);

        ListingLib.Status mstatus = marketplace.mockAssetListing(assetNft);
        (
            SaleConditions.Conditions memory mConditions,
            SaleConditions.ExtraSaleTerms memory mExtras
        ) = marketplace.mockSaleConditions(assetNft);

        vm.stopPrank();

        return (mstatus, mConditions, mExtras);
    }

    function _createAssetOffer(
        SaleConditions.Conditions memory mConditions,
        SaleConditions.ExtraSaleTerms memory mExtras
    ) internal returns (OfferApproval.Approval memory) {
        vm.startPrank(owner);
        OfferApproval.Approval memory mApproval = marketplace
            .approveSaleOfAtFloorPrice(assetNft, alice, mConditions, mExtras);
        vm.stopPrank();

        return mApproval;
    }

    function _buyerApproveMarketplaceAsSpenderAndDepositERC20(
        OfferApproval.Approval memory mApproval
    ) internal {
        vm.startPrank(alice);
        IERC20(address(USDC)).approve(address(marketplace), mApproval.price);
        marketplace.emitDepositAskAndBuyerDepositWithERC20Approved(
            assetNft,
            address(USDC),
            "USDC",
            mApproval
        );
        vm.stopPrank(); // stop pranking alice
    }

    function _sellerApproveMarketplaceAsSpenderAndDepositAssetNft() internal {
        vm.startPrank(owner);
        assetNft.approve(address(marketplace), 0);
        marketplace.sellerDepositAssetNft(assetNft);
        vm.stopPrank(); // stop pranking owner
    }

    function _assetListingToAllDeposit() internal {
        (
            ListingLib.Status mstatus,
            SaleConditions.Conditions memory mConditions,
            SaleConditions.ExtraSaleTerms memory mExtras
        ) = _listAssetWithConditions();

        OfferApproval.Approval memory mApproval = _createAssetOffer(
            mConditions,
            mExtras
        );

        // Deposit updates
        _mintUSDCTo(alice, mApproval.price + (12940124 * 10**18));
        _buyerApproveMarketplaceAsSpenderAndDepositERC20(mApproval);

        _sellerApproveMarketplaceAsSpenderAndDepositAssetNft();
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

        ////////////////// Verify AssetListing values //////////////////

        ////////////////// Verify SaleConditions values //////////////////
    }

    function testApproveSaleAtFloorPriceFailsOnAssetNotListed() public {
        vm.expectRevert("ASSET_NOT_LISTED");
        marketplace.approveSale(assetNft, alice, conditionsSetUp, extrasSetUp);
    }

    function testApproveSaleAtFloorPrice() public {
        vm.startPrank(owner);
        marketplace.listAssetWithSaleConditions(
            assetNft,
            conditionsSetUp,
            extrasSetUp
        );

        marketplace.approveSale(assetNft, alice, conditionsSetUp, extrasSetUp);

        ////////////////// Verify OfferAproval values //////////////////
        (
            address seller,
            address buyer,
            bool atFloorPrice,
            uint256 price,
            uint256 approvalTimestamp,
            SaleConditions.Conditions memory conditions,
            SaleConditions.ExtraSaleTerms memory extras,
            bool ownerSignature
        ) = marketplace.approvedOfferOf(assetNft);
        assertEq(seller, owner);
        assertEq(buyer, alice);
        assertTrue(atFloorPrice);
        assertEq(price, conditionsSetUp.floorPrice);
        assertEq(approvalTimestamp, block.timestamp);
        // SaleConditions.Conditions checks
        assertEq(conditions.floorPrice, conditionsSetUp.floorPrice);
        assertEq(
            conditions.paymentTerms.consummationSaleTimeframe,
            conditionsSetUp.paymentTerms.consummationSaleTimeframe
        );
        // SaleConditions.ExtraSaleTerms checks
        assertEq(extras.label, extrasSetUp.label);
        assertEq(
            extras.customTermDescription,
            extrasSetUp.customTermDescription
        );
        assertTrue(ownerSignature);

        ////////////////// Verify Deposit values //////////////////
        (
            Deposit.DepositState memory state,
            Deposit.ApprovalResume memory approval,
            ,

        ) = marketplace.depositedDataOf(assetNft);
        // Deposit.DepositState checks
        assertEq(uint256(state.status), uint256(Deposit.DepositStatus.Pending));
        assertFalse(state.isAssetLocked);
        // Deposit.ApprovalResume checks
        assertEq(approval.seller, owner);
        assertEq(approval.buyer, alice);
        assertEq(approval.price, conditionsSetUp.floorPrice);
    }

    function testApproveSaleAtCustomPrice() public {
        vm.startPrank(owner);
        marketplace.listAssetWithSaleConditions(
            assetNft,
            conditionsSetUp,
            extrasSetUp
        );

        uint256 customPrice = 2590325 * 10**18;
        marketplace.approveSale(
            assetNft,
            alice,
            customPrice,
            conditionsSetUp,
            extrasSetUp
        );

        ////////////////// Verify OfferAproval values //////////////////
        (
            address seller,
            address buyer,
            bool atFloorPrice,
            uint256 price,
            uint256 approvalTimestamp,
            SaleConditions.Conditions memory conditions,
            SaleConditions.ExtraSaleTerms memory extras,
            bool ownerSignature
        ) = marketplace.approvedOfferOf(assetNft);
        assertEq(seller, owner);
        assertEq(buyer, alice);
        assertFalse(atFloorPrice);
        // Price of the offer is not the floor price of the asset
        assertFalse(price == conditions.floorPrice);
        assertEq(price, customPrice);
        assertEq(approvalTimestamp, block.timestamp);
        // SaleConditions.Conditions checks
        assertEq(conditions.floorPrice, conditionsSetUp.floorPrice);
        assertEq(
            conditions.paymentTerms.consummationSaleTimeframe,
            conditionsSetUp.paymentTerms.consummationSaleTimeframe
        );
        // SaleConditions.ExtraSaleTerms checks
        assertEq(extras.label, extrasSetUp.label);
        assertEq(
            extras.customTermDescription,
            extrasSetUp.customTermDescription
        );
        assertTrue(ownerSignature);

        ////////////////// Verify Deposit values //////////////////
        (
            Deposit.DepositState memory state,
            Deposit.ApprovalResume memory approval,
            ,

        ) = marketplace.depositedDataOf(assetNft);
        // Deposit.DepositState checks
        assertEq(uint256(state.status), uint256(Deposit.DepositStatus.Pending));
        assertFalse(state.isAssetLocked);
        // Deposit.ApprovalResume checks
        assertEq(approval.seller, owner);
        assertEq(approval.buyer, alice);
        assertEq(approval.price, customPrice);
    }

    function testBuyerWholeDepositFailsOnBuyerNotApproved() public {
        vm.expectRevert("BUYER_NOT_APPROVED");
        marketplace.buyerWholeDepositERC20(assetNft, address(USDC), "USDC");
    }

    function testBuyerWholeDeposit() public {
        _mintUSDCTo(alice, 6450592 * 10**18);

        vm.startPrank(owner);
        marketplace.listAssetWithSaleConditions(
            assetNft,
            conditionsSetUp,
            extrasSetUp
        );

        marketplace.approveSale(assetNft, alice, conditionsSetUp, extrasSetUp);
        vm.stopPrank();

        vm.startPrank(alice);
        USDC.approve(address(marketplace), conditionsSetUp.floorPrice);
        marketplace.buyerWholeDepositERC20(assetNft, address(USDC), "USDC");

        ////////////////// Verify DepositData.BuyerData values //////////////////
    }

    function testResetSale() public {
        NoEmptyValueTest noEmptyValue = new NoEmptyValueTest();
        EmptyValueTest emptyValue = new EmptyValueTest();

        _assetListingToAllDeposit();

        noEmptyValue.verifiesAssetIsListed(marketplace, assetNft);
        noEmptyValue.verifySaleCondtionsAreNotEmpty(marketplace, assetNft);
        noEmptyValue.verifyAssetOfferAprovalIsNotEmpty(marketplace, assetNft);
        noEmptyValue.verifyDepositDataAreNotEmpty(marketplace, assetNft);

        marketplace.resetSaleAfterConsummation(assetNft);

        emptyValue.verifiesAssetIsNotListed(marketplace, assetNft);
        emptyValue.verifySaleCondtionsAreEmpty(marketplace, assetNft);
        emptyValue.verifyAssetOfferAprovalIsEmpty(marketplace, assetNft);
        emptyValue.verifyDepositDataAreEmpty(marketplace, assetNft);
    }
}
