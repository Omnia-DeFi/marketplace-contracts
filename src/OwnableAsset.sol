// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";

contract OwnableAsset {
    modifier onlyAssetOwner(AssetNft assetNft) {
        require(isAssetOwner(assetNft), "NOT_OWNER");
        _;
    }

    function isAssetOwner(AssetNft assetNft) public view returns (bool) {
        return assetNft.ownerOf(0) == msg.sender;
    }
}
