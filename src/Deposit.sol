// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";
import {SaleConditions} from "./SaleConditions.sol";
import {OfferApproval} from "./OfferApproval.sol";
import {OwnableAsset} from "./OwnableAsset.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";

/**
 * @notice Once, the asset offer has been approved by the seller it
 *         triggers a deposit ask for both sides, starting with the buyer,
 *         and informs users about the deposit status.
 *
 *         The buyer has to deposit the whole amount of the asset offer.
 */
abstract contract Deposit is ERC721TokenReceiver {
    event DepositAsked(AssetNft indexed asset, DepositState indexed approval);
    event BuyerDeposit(
        AssetNft indexed asset,
        BuyerData indexed data,
        DepositState indexed state,
        uint256 depositTime
    );
    event SellerDeposit(
        AssetNft indexed asset,
        SellerData indexed data,
        DepositState indexed state,
        uint256 depositTime
    );

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
        BuyerData buyerData;
        SellerData sellerData;
    }

    mapping(AssetNft => DepositState) public depositStateOf;
    mapping(AssetNft => DepositData) public depositedDataOf;

    /** @dev The buyer (msg.sender) must be the one approved by the seller in
     *        OfferApproval.Approval.
     */
    modifier onlyApprovedBuyer(AssetNft asset) {
        require(
            msg.sender == depositStateOf[asset].approval.buyer,
            "BUYER_NOT_APPROVED"
        );
        _;
    }

    modifier buyerDepositFirst(AssetNft asset) {
        require(
            depositStateOf[asset].status == DepositStatus.BuyerFullDeposit,
            "BUYER_DEPOSIT_FIRST"
        );
        _;
    }

    modifier allDepositMade(AssetNft asset) {
        require(
            depositStateOf[asset].status == DepositStatus.AllDepositMade,
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
    function _buyerWholeDepositERC20(
        AssetNft asset,
        address erc20,
        string memory erc20Label
    ) internal onlyApprovedBuyer(asset) {
        uint256 transferAmount = depositStateOf[asset].approval.price;

        IERC20(erc20).transferFrom(msg.sender, address(this), transferAmount);

        depositedDataOf[asset].buyerData.currencyAddress = erc20;
        depositedDataOf[asset].buyerData.symbol = erc20Label;
        depositedDataOf[asset].buyerData.amount = transferAmount;
        // Update status of the deposit & lock the asset
        depositStateOf[asset].status = DepositStatus.BuyerFullDeposit;
        depositStateOf[asset].isAssetLocked = true;

        emit BuyerDeposit(
            asset,
            depositedDataOf[asset].buyerData,
            depositStateOf[asset],
            block.timestamp
        );
    }

    /**
     * @notice Whole deposit from seller after buyer did deposit the currency.
     * @dev Transfer AssetNft from msg.sender (buyer) to this deposit contract.
     */
    function _sellerDepositAssetNft(AssetNft asset)
        internal
        buyerDepositFirst(asset)
    {
        asset.safeTransferFrom(msg.sender, address(this), 0);

        depositedDataOf[asset].sellerData.hasSellerDepositedAll = true;
        depositedDataOf[asset].sellerData.amount = 1;

        depositStateOf[asset].status = DepositStatus.AllDepositMade;

        emit SellerDeposit(
            asset,
            depositedDataOf[asset].sellerData,
            depositStateOf[asset],
            block.timestamp
        );
    }

    /**
     * @notice Once all deposit made and SaleConditions are still met, we swap the assets:
     *         - Buyer receives the `AssetNft`
     *         - Seller receives the `ERC20`
     * @param asset The listed `AssetNft` with an `OfferApproval` linked, that the buyer
     *              will receive.
     */
    function _swapAssets(AssetNft asset) internal allDepositMade(asset) {
        // transfer AssetNft from this contract to the buyer
        asset.safeTransferFrom(
            address(this),
            depositStateOf[asset].approval.buyer,
            0
        );

        // transfer ERC20 from this contract to the seller
        IERC20(depositedDataOf[asset].buyerData.currencyAddress).transfer(
            depositStateOf[asset].approval.seller,
            depositedDataOf[asset].buyerData.amount
        );
    }
}
