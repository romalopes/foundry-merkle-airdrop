// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    // Errors
    error ClaimAirdrop_SignatureLengthError(uint256 _signatureLength);

    address private constant CLAIMING_ADDRESS = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    uint256 private constant AMOUNT = 25 * 1e18;
    bytes32 private constant PROOF1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private proof = [PROOF1, PROOF2];
    bytes private constant SIGNATURE =
        hex"a64030c878c0a9deb859cf55f71539aeba64e79018965bc7f231aca4a6b441bf4828d7c95b73649ef57be12b9a6bba8703a6e8a6afc9190a3e5280ea8a69a0091c";

    function claimAirdrop(MerkleAirdrop merkleAirdrop) public {
        vm.startBroadcast();

        // (v, r, s) = stdJson.decodeFromHex(SIGNATURE);
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        merkleAirdrop.claim(CLAIMING_ADDRESS, AMOUNT, proof, v, r, s);

        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedAddress = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        MerkleAirdrop merkleAirdrop = MerkleAirdrop(mostRecentDeployedAddress);
        claimAirdrop(merkleAirdrop);
    }

    function splitSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature.length == 65, ClaimAirdrop_SignatureLengthError(signature.length));
        // bytes memory sig = bytes(signature);
        // v = sig[0];
        // r = bytes32(sig[1..33]);
        // s = bytes32(sig[33..65]);
        assembly {
            // r := mload(add(signature, 0x20))
            // s := mload(add(signature, 0x40))
            // v := byte(0, mload(add(signature, 0x60)))
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}
