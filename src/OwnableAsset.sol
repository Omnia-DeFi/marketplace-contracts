// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";

/**
 * @dev Defines a modifier for ownership verification of an asset.
 */
//TODO: For now we consider that only ID 0 is minted in AssetNft & that
// being the owner means having a blalance != 0
abstract contract OwnableAsset {
    modifier onlyAssetOwner(AssetNft assetNft) {
        require(isAssetOwner(assetNft), "NOT_OWNER");
        _;
    }

    /// @dev For now only ERC-11555 of id 0 will minted to represent shares.
    function isAssetOwner(AssetNft assetNft) public view returns (bool) {
        return assetNft.balanceOf(msg.sender, 0) > 0;
    }
}
