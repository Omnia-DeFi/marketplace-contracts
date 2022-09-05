import {OfferApproval, AssetNft, SaleConditions} from "../../src/OfferApproval.sol";

library OfferApprovalCreateFetch {
    function createFloorPriceApproval(
        address seller,
        address buyer,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public view returns (OfferApproval.Approval memory approval) {
        approval.seller = seller;
        approval.buyer = buyer;
        approval.atFloorPrice = true;
        approval.price = 650000 * 10**18;
        approval.approvalTimestamp = block.timestamp;
        approval.conditions = conditions;
        approval.extras = extras;
        approval.ownerSignature = true;
    }

    function createCustomPriceApproval(
        address seller,
        address buyer,
        uint256 price,
        SaleConditions.Conditions memory conditions,
        SaleConditions.ExtraSaleTerms memory extras
    ) public view returns (OfferApproval.Approval memory approval) {
        approval.seller = seller;
        approval.buyer = buyer;
        approval.atFloorPrice = false;
        approval.price = price;
        approval.approvalTimestamp = block.timestamp;
        approval.conditions = conditions;
        approval.extras = extras;
        approval.ownerSignature = true;
    }

    function approvedOfferOf(OfferApproval from, AssetNft asset)
        public
        view
        returns (OfferApproval.Approval memory approval)
    {
        (
            approval.seller,
            approval.buyer,
            approval.atFloorPrice,
            approval.price,
            approval.approvalTimestamp,
            approval.conditions,
            approval.extras,
            approval.ownerSignature
        ) = from.approvedOfferOf(asset);
    }
}
