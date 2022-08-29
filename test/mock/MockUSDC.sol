// SPDX-License-Identifier: SPDX-2.0-or-later
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20("USDC", "USDC") {
    constructor() {
        _mint(msg.sender, 10**6 * 10**18); // 1 million USDC to msg.sender
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
