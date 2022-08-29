// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OfferApproval} from "./OfferApproval.sol";
import {OwnableAsset} from "./OwnableAsset.sol";

/**
 * @notice Once, the asset offer has been approved by the seller it
 *         triggers a deposit ask for both sides, starting with the buyer,
 *         and informs users about the deposit status.
 *
 *         The buyer has to deposit the whole amount of the asset offer.
 */
contract Deposit {
    address constant USDC = address(0x0);

    event DepositAsked(AssetNft indexed asset, DepositState indexed approval);
    event BuyerDeposit(
        address buyer,
        address indexed asset,
        string indexed currency,
        uint256 indexed amount
    );
    event SellerDeposit(address indexed asset);

    enum DepositStatus {
        Void,
        Pending,
        BuyerFullDeposit,
        SellerFullDeposit,
        AllDepositMade
    }

    struct DepositState {
        DepositStatus status;
        bool isAssetLocked;
        OfferApproval.Approval approval;
    }

    struct Currency {
        // IERC20 address;
        string symbol;
        uint256 amount;
    }
    struct AssetShares {
        AssetNft asset;
        uint256 amount;
    }

    struct DepositedAssets {
        Currency currency;
        AssetShares shares;
    }

    mapping(AssetNft => DepositState) public depositStateOf;
    mapping(AssetNft => DepositedAssets) public depositedAssetsOf;

    /**
     * @notice Ask both parties engaged in the sale to deposit their
     *         due, starting with the buyer.
     * @dev DepositState.isAssetLocked is set to false by default.
     *
     * @param asset The contract representing the asset.
     * @param approval The approval of the asset offer.
     */
    function _emitDepositAsk(
        AssetNft asset,
        OfferApproval.Approval memory approval
    ) internal {
        // Update status and approval. Asset is not locked as not deposit has beeen made
        // yet. By default a bollean is false, so no need to update it to false.
        depositStateOf[asset].status = DepositStatus.Pending;
        depositStateOf[asset].approval = approval;

        emit DepositAsked(asset, depositStateOf[asset]);
    }

    /**
     * @notice Whole deposit from buyer according to the price agreed in OfferApproval,
     *         only using ERC20 tokens.``
     * @dev Transfer ERC20 from msg.sender (buyer) to this deposit contract.
     *      For the first version we will asume only USDC will be used.
     */
    function _buyerWholeDepositERC20(AssetNft asset) internal {
        uint256 transferAmount = depositStateOf[asset].approval.price;

        // IERC20(USDCaddr).transferFrom(msg.sender, this, transferAmount);

        depositedAssetsOf[asset].currency.symbol = "USDC";
        depositedAssetsOf[asset].currency.amount = transferAmount;

        depositStateOf[asset].status = DepositStatus.BuyerFullDeposit;
    }
}
