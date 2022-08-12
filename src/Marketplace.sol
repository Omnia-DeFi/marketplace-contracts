// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";

/**
 * @notice Marketplace to list an asset with a floor price defined by the owner while
 *        allowing the buyer to place a buy request at floor price.
 *              (or later to place new bid)
 *
 *        Once the seller approves the buy (or bid) request. This triggers a dposit ask.
 */
contract Marketplace {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AssetListedForSale(
        AssetNft assetNft,
        uint256 assetId,
        uint256 floorPrice
    );

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/
    /// @dev USD price only has 2 decimals.
    uint256 public constant USD_PRICE_DECIMAL = 10**2;

    /*//////////////////////////////////////////////////////////////
                                 PRICING LOGIC
    //////////////////////////////////////////////////////////////*/
    ///@dev AssetNft => Asset ID => Floor Price
    mapping(AssetNft => mapping(uint256 => uint256)) public floorPriceOf;

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyAssetOwner(AssetNft assetNft, uint256 assetId) {
        require(assetNft.ownerOf(assetId) == msg.sender, "NOT_OWNER");
        _;
    }
    modifier priceAboveZero(uint256 price) {
        require(price > 0, "ZERO_FLOOR_PRICE");
        _;
    }

    /**
     * @dev List an asset for sale with a floor price in USD.
     *
     * @param assetNft The asset to list for sale.
     * @param floorPrice The floor price in USD.
     *
     * Requirements:
     * - only the asset owner can list an asset for sale.
     * - the asset price must be greater than 0.
     */
    function listAssetForSale(
        AssetNft assetNft,
        uint256 assetId,
        uint256 floorPrice
    ) public onlyAssetOwner(assetNft, assetId) priceAboveZero(floorPrice) {
        floorPriceOf[assetNft][assetId] = floorPrice;

        emit AssetListedForSale(assetNft, assetId, floorPrice);
    }
}
