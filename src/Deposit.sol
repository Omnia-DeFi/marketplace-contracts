// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OfferApproval} from "./OfferApproval.sol";
import {OwnableAsset} from "./OwnableAsset.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";

/**
 * @notice Once, the asset offer has been approved by the seller it
 *         triggers a deposit ask for both sides, starting with the buyer,
 *         and informs users about the deposit status.
 *
 *         The buyer has to deposit the whole amount of the asset offer.
 */
abstract contract Deposit is ERC1155TokenReceiver {
    event DepositAsked(AssetNft indexed asset, ApprovalResume indexed approval);
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
    event DepositDataReset(AssetNft indexed asset, uint256 timestamp);

    enum DepositStatus {
        Void,
        Pending,
        BuyerFullDeposit,
        SellerFullDeposit,
        AllDepositMade
    }

    struct ApprovalResume {
        address seller;
        address buyer;
        uint256 price;
    }

    struct DepositState {
        DepositStatus status;
        bool isAssetLocked;
    }

    struct BuyerData {
        address currencyAddress;
        string symbol;
        uint256 amount;
    }
    struct SellerData {
        bool hasSellerDepositedAll;
        uint256 amount;
    }

    struct DepositData {
        DepositState state;
        ApprovalResume approval;
        BuyerData buyerData;
        SellerData sellerData;
    }

    mapping(AssetNft => DepositData) public depositedDataOf;

    /** @dev The buyer (msg.sender) must be the one approved by the seller in
     *        OfferApproval.Approval.
     */
    modifier onlyApprovedBuyer(AssetNft asset) {
        require(
            msg.sender == depositedDataOf[asset].approval.buyer,
            "BUYER_NOT_APPROVED"
        );
        _;
    }

    modifier buyerDepositFirst(AssetNft asset) {
        require(
            depositedDataOf[asset].state.status ==
                DepositStatus.BuyerFullDeposit,
            "BUYER_DEPOSIT_FIRST"
        );
        _;
    }

    modifier onAllDepositMade(AssetNft asset) {
        require(
            depositedDataOf[asset].state.status == DepositStatus.AllDepositMade,
            "MISSING_DEPOSIT"
        );
        _;
    }

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
        depositedDataOf[asset].state.status = DepositStatus.Pending;
        depositedDataOf[asset].approval.seller = approval.seller;
        depositedDataOf[asset].approval.buyer = approval.buyer;
        depositedDataOf[asset].approval.price = approval.price;

        emit DepositAsked(asset, depositedDataOf[asset].approval);
    }

    /**
     * @notice Whole deposit from buyer according to the price agreed in OfferApproval,
     *         only using ERC20 tokens.``
     * @dev Transfer ERC20 from msg.sender (buyer) to this deposit contract.
     *      For the first version we will asume only USDC will be used.
     */
    function _buyerWholeDepositERC20(
        AssetNft asset,
        address erc20,
        string memory erc20Label
    ) internal onlyApprovedBuyer(asset) {
        uint256 transferAmount = depositedDataOf[asset].approval.price;

        // TODO: implement Oracle to convert `transferAmount` USD into `erc20` amount.
        IERC20(erc20).transferFrom(msg.sender, address(this), transferAmount);

        depositedDataOf[asset].buyerData.currencyAddress = erc20;
        depositedDataOf[asset].buyerData.symbol = erc20Label;
        depositedDataOf[asset].buyerData.amount = transferAmount;
        // Update status of the deposit & lock the asset
        depositedDataOf[asset].state.status = DepositStatus.BuyerFullDeposit;
        depositedDataOf[asset].state.isAssetLocked = true;

        emit BuyerDeposit(asset, depositedDataOf[asset], block.timestamp);
    }

    /**
     * @notice Whole deposit from seller after buyer did deposit the currency.
     * @dev Transfer AssetNft from msg.sender (buyer) to this deposit contract.
     */
    function _sellerDepositAssetNft(AssetNft asset)
        internal
        buyerDepositFirst(asset)
    {
        // TODO: only transfer id 0
        asset.safeTransferFrom(
            msg.sender,
            address(this),
            0,
            asset.balanceOf(msg.sender, 0),
            bytes("")
        );

        depositedDataOf[asset].sellerData.hasSellerDepositedAll = true;
        depositedDataOf[asset].sellerData.amount = 1;

        depositedDataOf[asset].state.status = DepositStatus.AllDepositMade;

        emit SellerDeposit(asset, depositedDataOf[asset], block.timestamp);
    }

    /**
     * @notice Once all deposit made and SaleConditions are still met, we swap the assets:
     *         - Buyer receives the `AssetNft`
     *         - Seller receives the `ERC20`
     * @param asset The listed `AssetNft` with an `OfferApproval` linked, that the buyer
     *              will receive.
     */
    function _swapAssets(AssetNft asset) internal onAllDepositMade(asset) {
        // transfer AssetNft from this contract to the buyer
        // TODO: only transfer id 0
        asset.safeTransferFrom(
            address(this),
            depositedDataOf[asset].approval.buyer,
            0,
            asset.balanceOf(address(this), 0),
            bytes("")
        );

        // transfer ERC20 from this contract to the seller
        IERC20(depositedDataOf[asset].buyerData.currencyAddress).transfer(
            depositedDataOf[asset].approval.seller,
            depositedDataOf[asset].buyerData.amount
        );
    }

    function _resetDepositData(AssetNft asset) internal {
        delete depositedDataOf[asset];

        emit DepositDataReset(asset, block.timestamp);
    }
}
