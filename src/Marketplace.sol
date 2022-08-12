// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";

/**
 * @notice Marketplace to list an asset with a floor price defined by the owner while
 *        allowing the buyer to place a buy request at floor price.
 *              (or later to place new bid)
 *
 *        Once the seller approves the buy (or bid) request, it triggers a dposit
 *        request.
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
     * @param assetNft The asset contract from which the asset originates.
     * @param assetId The asset ID of the exact asset to list for sale.
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

    /**
     * @dev The buyer places a buy request for an asset.
     *
     * Requirements:
     * - only one buy request can be placed for an asset. Placing a new buy request
     *   for an asset will overwrite the previous one.
     * - a buy request can be placed only if a deposit has not been done or sale is
     *   still going on.
     * - the asset owner can not place a buy request.
     */
    function placeBuyRequest(AssetNft assetNft, uint256 assetId) public {}

    /**
     * @dev The seller approves the buy request of a buyer.
     *
     * Requirements:
     * - only one single buy request can be approved at a time, which will triger a
     *   deposit request to the buyer.
     * - only the asset owner can approve a buy request.
     */
    function approveBuyRequest(
        AssetNft assetNft,
        uint256 assetId,
        address buyer
    ) public {
        // TODO: Desposit contract: trigger buy request, the buyer has 24 hours to deposit the funds or the buy request will be automatically voided.
    }

    /**
     * @dev The seller can void a buy request at any point in time by the seller,
     *      until before the desposit request is opened.
     */
    function voidBuyRequest(
        AssetNft assetNft,
        uint256 assetId,
        address buyer
    ) public {}

    /**
     * @dev Update the floor price of an asset.
     *
     * @param assetNft The asset contract from which the asset originates.
     * @param assetId The asset ID of the exact asset to list for sale.
     * @param floorPrice The floor price in USD.
     *
     * Requirements:
     * - once the seller has accepted a buy request from a buyer, the floor price can
     *   not be updated, until either the buyer withdraws their offer or the sale
     *   is terminated or consummated.
     * - only the asset owner can list an asset for sale.
     * - the asset price must be greater than 0.
     */
    function updateFloorPrice(
        AssetNft assetNft,
        uint256 assetId,
        uint256 floorPrice
    )
        public
        onlyAssetOwner(assetNft, assetId)
        priceAboveZero(floorPrice)
        returns (bool updated)
    {
        updated = false;
    }
}
