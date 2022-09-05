import {Deposit, AssetNft, SaleConditions, OfferApproval} from "../../src/Deposit.sol";

library DepositCreateFetch {
    function createDepositData(
        OfferApproval.Approval memory approval,
        address erc20Addrr,
        string memory erc20Symbol,
        bool isSeller,
        uint256 sellerAmount
    ) public view returns (Deposit.DepositData memory data) {
        data.approval.seller = approval.seller;
        data.approval.buyer = approval.buyer;
        data.approval.price = approval.price;

        data.buyerData.currencyAddress = erc20Addrr;
        data.buyerData.symbol = erc20Symbol;
        data.buyerData.amount = approval.price;

        data.state.status = isSeller
            ? Deposit.DepositStatus.AllDepositMade
            : Deposit.DepositStatus.BuyerFullDeposit;
        data.state.isAssetLocked = true;

        data.sellerData.hasSellerDepositedAll = isSeller;
        data.sellerData.amount = sellerAmount;
    }

    function depositedDataOf(Deposit deposit, AssetNft asset)
        public
        view
        returns (Deposit.DepositData memory data)
    {
        (
            Deposit.DepositState memory state,
            Deposit.ApprovalResume memory resume,
            Deposit.BuyerData memory buyer,
            Deposit.SellerData memory seller
        ) = deposit.depositedDataOf(asset);

        data.state = state;
        data.approval = resume;
        data.buyerData = buyer;
        data.sellerData = seller;
    }
}
