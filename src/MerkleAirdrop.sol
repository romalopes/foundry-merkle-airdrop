// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// import {MerkleTree} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    // Errors
    error MerkleAirdrop__MerkleProofInvalidMultiProof();
    error MerkleAirdrop__HasClaimed(address account, uint256 amount);
    error MerkleAirdrop__InvalidSignature();

    // Events
    event Claimed(address account, uint256 amount);

    // Varibles
    // Merkle tree proofs
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private i_airDropToken;
    mapping(address claymer => bool claimed) public s_hasClaimed;

    constructor(bytes32 _merkleRoot, IERC20 _airDropToken) {
        i_merkleRoot = _merkleRoot;
        i_airDropToken = _airDropToken;
    }

    /*
    @dev claim the airdrop token    
    @param account the account to claim the airdrop token
    @param amount the amount of airdrop token to claim
    @param merkleProof the merkle proof
    @dev check if the account has already claimed the airdrop token
    @dev check/Efects/Interact 
    */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__HasClaimed(account, amount);
        }
        // calculate the hash using account and amount. -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        // check if the leaf is in the merkle tree
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__MerkleProofInvalidMultiProof();
        }

        // set the account as claimed
        s_hasClaimed[account] = true;

        emit Claimed(account, amount);
        // transfer the airdrop token to the account
        i_airDropToken.safeTransfer(account, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getClaimers() external view returns (address[] memory) {
        return claimers;
    }

    function getClaimed(address account) external view returns (bool) {
        return s_hasClaimed[account];
    }

    function getAirDropToken() external view returns (IERC20) {
        return i_airDropToken;
    }
}
