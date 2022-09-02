// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {AssetNft} from "omnia-nft/AssetNft.sol";

contract MockAssetNft is AssetNft {
    constructor(address owner) AssetNft("AssetMocked", "MA1", owner) {
        safeMint(owner, 0, "QmRa4ZuTB2FTqRUqdh1K9rwjx33E5LHKXwC3n6udGvpaPV");
    }
}
