// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {} from "openzeppelin-contracts/";

/**
 * @notice Marketplace to list an asset with a floor price defined by the owner while
 *        allowing the buyer to place a buy request at floor price or to place new bid.
 *
 *        Once the seller approves the bid or buy request, the buyer has to make a deposit,
 *        then the seller deposit the NFT.
 *        Once these steps are achieved, the legal process for real asset ownership transfer
 *        can start.
 *
 *        The solicitor must attach messages (containg documents links) that both or one
 *        specific party has to sign.
 *
 *        Then, the solicitor will trigger an ask to the buyer to deposit the whole funds in the
 *        coming 48h or the transaction will be voided enhance the buyer losing their deposit.
 *
 *        Once all document are signed by both parties the swap NFT <-> USDC will happen, enhance
 *        closing the deal.
 *        Buyer & seller are now legally binded and the last part of the transfer will happen IRL,
 *        outside of the blockchain, like key handling, asset shipping, etc....
 *
 *        __Note:__
 *        The buyer can void the sale at any point in time. If done after the ask from solicitor to
 *        deposit funds or once the deposit has been done, they will lose the deposit.
 *        The deposit will be splited between the solicitor and the seller.
 */
contract Marketplace {

}
