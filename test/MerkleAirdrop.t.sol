// SPDX-License-Identifier: MIT

pragma solidity >=0.8.24;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {console} from "forge-std/console.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address private gasPayer;
    address private user;
    uint256 private userPrivateKey;
    uint256 public AMOUNT = 25 * 1e18;
    bytes32 public proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proof1, proof2];

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (merkleAirdrop, bagelToken) = deployer.deployMerkleAirdrop();
        // bagelToken = new BagelToken();
        // merkleAirdrop = new MerkleAirdrop(ROOT, bagelToken);
        // bagelToken.mint(bagelToken.owner(), AMOUNT * 4);
        // bagelToken.transfer(address(merkleAirdrop), AMOUNT * 4);
        //from forge-stc/StdCheats.sol

        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        if (user == address(0)) {
            (user, userPrivateKey) = makeAddrAndKey("user");
            gasPayer = makeAddr("gasPayer");
        }

        bytes32 digestMessageHash = merkleAirdrop.getMessageHash(user, AMOUNT);

        console.log("user address 1: %s", user);
        uint256 startingBalance = bagelToken.balanceOf(user);
        console.log("Starting Balance %s", startingBalance);
        vm.prank(user);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digestMessageHash);
        // gasPayer calls claims using the signed message
        console.log("1");
        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT, PROOF, v, r, s);
        console.log("2");
        uint256 endingBalance = bagelToken.balanceOf(user);
        console.log("3");
        console.log("Ending Balance %s", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT);
        // merkleAirdrop.claim();
    }
}
