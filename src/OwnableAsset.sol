// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";

/**
 * @dev Defines a modifier for ownership verification of an asset.
 */
contract OwnableAsset {
    modifier onlyAssetOwner(AssetNft assetNft) {
        require(isAssetOwner(assetNft), "NOT_OWNER");
        _;
    }

    /// @dev For now only ERC-11555 of id 0 will minted to represent shares.
    function isAssetOwner(AssetNft assetNft) public view returns (bool) {
        return assetNft.ownerOf(0) == msg.sender;
    }
}
