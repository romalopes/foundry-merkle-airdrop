// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// "@openzeppelin-contracts/contracts/=lib/openzeppelin-contracts/contracts/",

contract BagelToken is ERC20, Ownable {
    constructor() ERC20("Bagel", "BGL") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
