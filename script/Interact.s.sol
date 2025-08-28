// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    address private constant CLAIMING_ADDRESS = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    uint256 private constant AMMOUNT = 25 * 1e18;
    bytes32 private constant PROOF1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private proof = [PROOF1, PROOF2];
    uint8 v;
    bytes32 r;
    bytes32 s;

    function claimAirdrop(MerkleAirdrop merkleAirdrop) public {
        vm.startBroadcast();
        merkleAirdrop.claim(CLAIMING_ADDRESS, AMMOUNT, proof, v, r, s);

        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedAddress = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        MerkleAirdrop merkleAirdrop = MerkleAirdrop(mostRecentDeployedAddress);
        claimAirdrop(merkleAirdrop);
    }
}
