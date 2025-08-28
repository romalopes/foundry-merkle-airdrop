// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// import {MerkleTree} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    // Errors
    error MerkleAirdrop__MerkleProofInvalidMultiProof();
    error MerkleAirdrop__HasClaimed(address account, uint256 amount);
    error MerkleAirdrop__InvalidSignature();

    // Events
    event Claimed(address account, uint256 amount);

    // define the message hash struct
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    // Varibles
    // Merkle tree proofs
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private i_airDropToken;
    mapping(address claymer => bool claimed) public s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    constructor(bytes32 _merkleRoot, IERC20 _airDropToken) EIP712("MerkleAirdrop", "1") {
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
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__HasClaimed(account, amount);
        }

        // check the signature
        // if signature is not valid
        // if (!ECDSA.verify(bytes.concat(abi.encode(account, amount), i_merkleRoot), v, r, s)) {
        // if(isValidSignature(bytes.concat(abi.encode(account, amount), i_merkleRoot), v, r, s)) {
        if (!isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
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

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            // keccak256(bytes.concat(abi.encode(account, amount)))
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount})))
        );
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

    function isValidSignature(address account, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        public
        pure
        returns (bool)
    {
        // (address signer) = ECDSA.recover(messageHash, v, r, s);
        (address signer,,) = ECDSA.tryRecover(messageHash, v, r, s);
        return signer == account;
    }
}
