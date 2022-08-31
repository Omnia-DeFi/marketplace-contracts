// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {Marketplace, ListingLib, AssetNft, SaleConditions, OfferApproval} from "src/Marketplace.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract MockMarketplace is Marketplace {
    function resetSaleAfterConsummation(AssetNft asset) public {
        _resetSaleAfterConsummation(asset);
    }

    function mockAssetListing(AssetNft asset)
        public
        returns (ListingLib.Status)
    {
        listingStatusOf[asset] = ListingLib.Status.ActiveListing;

        return listingStatusOf[asset];
    }

    function mockSaleConditions(AssetNft asset)
        public
        returns (Conditions memory, ExtraSaleTerms memory)
    {
        Conditions memory conditions = Conditions(
            1249014 * FIAT_PRICE_DECIMAL,
            PaymentTerms(24 hours)
        );
        ExtraSaleTerms memory extras = ExtraSaleTerms(
            "Label",
            "Custom Description"
        );

        _setSaleConditions(asset, conditions, extras);

        return (saleConditionsOf[asset], extraSaleConditionsOf[asset]);
    }

    function approveSaleOfAtFloorPrice(
        AssetNft asset,
        address buyer,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public returns (OfferApproval.Approval memory) {
        _approveSaleOfAtFloorPrice(asset, buyer, conditions, extras);

        return approvedOfferOf[asset];
    }

    function emitDepositAskAndBuyerDepositWithERC20Approved(
        AssetNft asset,
        address erc20,
        string memory erc20Label,
        OfferApproval.Approval memory approval
    ) public {
        _emitDepositAsk(asset, approval);
        _buyerWholeDepositERC20(asset, erc20, erc20Label);
    }

    function sellerDepositAssetNft(AssetNft asset) public {
        _sellerDepositAssetNft(asset);
    }

    function swapAssets(AssetNft asset) public {
        _swapAssets(asset);
    }
}
