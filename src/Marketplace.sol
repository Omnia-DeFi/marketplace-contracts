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
        AssetNft _assetNft,
        uint256 _assetId,
        uint256 _floorPrice
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

    /**
     * @dev List an asset for sale with a floor price in USD.
     *
     * @param _assetNft The asset to list for sale.
     * @param _floorPrice The floor price in USD.
     */
    function listAssetForSale(
        AssetNft _assetNft,
        uint256 _assetId,
        uint256 _floorPrice
    ) public {
        require(_assetNft.ownerOf(_assetId) == msg.sender, "NOT_OWNER");
        require(_floorPrice > 0, "ZERO_FLOOR_PRICE");

        floorPriceOf[_assetNft][_assetId] = _floorPrice;

        emit AssetListedForSale(_assetNft, _assetId, _floorPrice);
    }
}
