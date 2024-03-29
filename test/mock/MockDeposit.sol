// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {Deposit, AssetNft, SaleConditions, OfferApproval} from "../../src/Deposit.sol";

contract MockDeposit is Deposit {
    function emitDepositAsk(
        AssetNft asset,
        OfferApproval.Approval memory approval
    ) public {
        _emitDepositAsk(asset, approval);
    }

    function buyerWholeDepositERC20(
        AssetNft asset,
        address erc20,
        string memory erc20Label
    ) public {
        _buyerWholeDepositERC20(asset, erc20, erc20Label);
    }

    function sellerDepositAssetNft(AssetNft asset) public {
        _sellerDepositAssetNft(asset);
    }

    function swapAssets(AssetNft asset) public {
        _swapAssets(asset);
    }
}
