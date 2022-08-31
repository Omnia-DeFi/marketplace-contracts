// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./libraries/ListingLib.sol";
import {AssetNft} from "omnia-nft/AssetNft.sol";
import {AssetListing} from "./AssetListing.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OfferApproval} from "./OfferApproval.sol";
import {Deposit} from "./Deposit.sol";

/**
 * @notice Marketplace is the orchestrator contract. It is responsible
 *         to link all the contracts engaged in a sale from the listing
 *         to the swap of assets (currency <-> NFTs).
 *
 *         It also registers the currencies accepted to buy NFTs.
 *
 * @dev Connects AssetListing, SaleConditions, AssetOfferAproval,
 *      Deposit & SaleConsummation contracts together.
 */
contract Marketplace is AssetListing, SaleConditions, OfferApproval, Deposit {
    event SaleConsummated(
        address indexed asset,
        address indexed buyer,
        SaleConditions indexed conditions,
        Deposit deposit
    );

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/
    /// @dev USD price only has 2 decimals.
    uint256 public constant FIAT_PRICE_DECIMAL = 10**2;

    enum SaleSate {
        Null,
        Processing,
        Consummated,
        Voided,
        Cancelled
    }

    mapping(AssetNft => SaleSate) public saleStateOf;

    modifier onlyListedAsset(AssetNft asset) {
        require(
            listingStatusOf[asset] == ListingLib.Status.ActiveListing,
            "ASSET_NOT_LISTED"
        );
        _;
    }

    // TODO: implement logic to verify a sale has been voided
    // TODO: Test the modifier on its on failure cases
    modifier onSaleVoided(AssetNft asset) {
        _;
    }

    // TODO: implement logic to verify a sale has been consummated
    // TODO: Test the modifier on its on failure cases
    modifier onSaleConsummated(AssetNft asset) {
        _;
    }

    /**
     * @notice List an asset for sale on the marketplace with compulsory sale conditions
     *         and optional extra sale terms.
     * @dev Merge `AssetListing` & `SaleConditions` logic.
     */
    function listAssetWithSaleConditions(
        AssetNft asset,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public {
        _listAsset(asset);
        _setSaleConditions(asset, conditions, extras);
    }

    /**
     * @notice Once all sale conditions are met, the sale of the asset is
     *         consummated and the swap is instantly made. Each side wil
     *         receive their respective assets.
     *
     * @param asset The asset to be consummated.
     * @param buyer The buyer of the asset.
     * @param conditions The sale conditions of the asset.
     * @param deposit The deposit contractcontaing the currency and the
     *                NFTs.
     *
     * @return Sale consummation success or failure.
     */
    function consummateSale(
        address asset,
        address buyer,
        SaleConditions conditions,
        Deposit deposit
    ) external returns (bool) {}

    /**
     * see documentation of: OfferApproval._approveSaleOfAtFloorPrice &
     *                       Deposit._emitDepositAsk
     * @notice Approve a buy request from a specific buyer for a specific NFT asset at floor
     *      price.
     * @dev `onlyListedAsset` verifies that the asset is listed, otherwise fails.
     */
    function approveSale(
        AssetNft asset,
        address buyer,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public onlyListedAsset(asset) noSaleInProcess(asset) {
        _approveSaleOfAtFloorPrice(asset, buyer, conditions, extras);
        _emitDepositAsk(asset, approvedOfferOf[asset]);

        saleStateOf[asset] = SaleSate.Processing;
    }

    // TODO: test edges cases with `noSaleInProcess`
    /**
     * @notice Overload `approveSale` with custom price.
     */
    function approveSale(
        AssetNft asset,
        address buyer,
        uint256 salePrice,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) external onlyListedAsset(asset) {
        _approveSaleOfAtCustomPrice(
            asset,
            buyer,
            salePrice,
            conditions,
            extras
        );
        _emitDepositAsk(asset, approvedOfferOf[asset]);

        saleStateOf[asset] = SaleSate.Processing;
    }

    // TODO: test edges cases with `noSaleInProcess`
    function buyerWholeDepositERC20(
        AssetNft asset,
        address erc20,
        string memory erc20Label
    ) public {
        _buyerWholeDepositERC20(asset, erc20, erc20Label);
    }

    // TODO: add event and test failure and edges cases
    // TODO: add an attribute and update variables somewhere to mark this call as sale consummated
    /**
     * @notice Reset all data related to a sale of an asset.
     * @dev All deposits (buyer and seller) must have been made and sale must be marked as
     *      consummated.
     */
    function _resetSaleAfterConsummation(AssetNft asset)
        internal
        onAllDepositMade(asset)
        onSaleConsummated(asset)
    {
        _unlistAsset(asset);
        _resetSaleConditions(asset);
        _resetAssetOfferApproval(asset);
        _resetDepositData(asset);
    }
}
