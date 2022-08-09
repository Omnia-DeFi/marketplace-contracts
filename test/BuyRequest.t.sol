// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/BuyRequest.sol";

contract BuyRequestTest is Test {
    BuyRequest buyRequest;

    /*//////////////////////////////////////////////////////////////
						  IMPERSONATED ADDRESSES
	//////////////////////////////////////////////////////////////*/
    address immutable assetNft = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address immutable owner = msg.sender;
    address immutable alice = 0x065e3DbaFCb2C26A978720f9eB4Bce6aD9D644a1;
    address immutable bob = 0x7F101fE45e6649A6fB8F3F8B43ed03D353f2B90c;
    address immutable conveyancer = 0xab3B229eB4BcFF881275E7EA2F0FD24eeaC8C83a;
    address immutable solicitor = 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8;
    address immutable omnia = 0x1aD91ee08f21bE3dE0BA2ba6918E714dA6B45836;

    function setUp() public {
        buyRequest = new BuyRequest();
    }

    function testNoCurrentBuyRequestOfAlice() public {
        (
            address buyer,
            address assetowner,
            address asset,
            uint256 assetId,
            uint256 price,
            uint256 timestamp,
            bool approved,
            bytes32 signature
        ) = buyRequest.currentBuyRequestsOf(alice, 0);

        assertEq(buyer, address(0));
        assertEq(assetowner, address(0));
        assertEq(asset, address(0));
        assertEq(assetId, 0);
        assertEq(price, 0);
        assertEq(timestamp, 0);
        assertEq(approved, false);
        assertEq(signature, bytes32(0));
    }

    /// @notice Buyer issue a buy request on-chain for an asset NFT.
    /// As this is a buy request and not a bid, it will use NFT floor price

    /// @notice Checks signature and mapping update after buy request

    /// @notice Seller approves the buy request on-chain
}
