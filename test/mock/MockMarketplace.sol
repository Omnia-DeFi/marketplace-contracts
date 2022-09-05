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

    function setSaleConditions(
        AssetNft asset,
        Conditions memory conditions,
        ExtraSaleTerms memory extras
    ) public {
        _setSaleConditions(asset, conditions, extras);
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

    function setSaleStateAsConsummated(AssetNft asset) public {
        saleStateOf[asset] = SaleSate.Consummated;
    }

    function consummateSale(AssetNft asset) public {
        _consummateSale(asset);
    }
}
