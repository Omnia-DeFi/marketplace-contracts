// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {} from "openzeppelin-contracts/";

/**
 * @notice Contract that allows a buyer of an asset NFT to send a buy request to the seller.
 *         The seller will then approve or reject the request.
 */
contract BuyRequest {
    struct BuyRequest {
        address buyer;
        address assetOwner;
        address asset;
        uint256 assetId;
        uint256 price;
        uint256 timestamp;
        bool approved;
        bytes32 signature;
    }

    mapping(address => mapping(uint256 => BuyRequest))
        public currentBuyRequestsOf;

    /**
     * @notice Creates a buy request for an asset NFT using floor price.
     *
     * @param assetId The id of the asset NFT.
     * @param signature The buy request signature valid for 72h.
     */
}
