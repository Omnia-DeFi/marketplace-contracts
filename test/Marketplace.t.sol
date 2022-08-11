// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/Marketplace.sol";
import {AssetNft} from "omnia-nft/AssetNft.sol";

contract MarketplaceTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AssetListedForSale(
        AssetNft _assetNft,
        uint256 _assetId,
        uint256 _floorPrice
    );

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    address immutable owner = 0xbB0007bc73E7e683537A17e46b8100EAd6a8c577;
    address immutable alice = 0x065e3DbaFCb2C26A978720f9eB4Bce6aD9D644a1;
    address immutable bob = 0x7F101fE45e6649A6fB8F3F8B43ed03D353f2B90c;
    address immutable conveyancer = 0xab3B229eB4BcFF881275E7EA2F0FD24eeaC8C83a;
    address immutable solicitor = 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8;
    address immutable omnia = 0x1aD91ee08f21bE3dE0BA2ba6918E714dA6B45836;

    /*//////////////////////////////////////////////////////////////
                                 ASSET
    //////////////////////////////////////////////////////////////*/
    AssetNft public assetNft;
    uint256 assetPrice;

    Marketplace marketplace;

    function setUp() public {
        marketplace = new Marketplace();
        assetNft = new AssetNft(owner);
        assetPrice = 650000 * marketplace.USD_PRICE_DECIMAL();
    }
    }

    /// @notice List an asset with a floor price.

    /// @notice The solicitor attach multiple messages to sign documents.
}
