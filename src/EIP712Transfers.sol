// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract EIP712Transfers is EIP712 {
    using ECDSA for bytes32;

    // EIP-712 domain: name = "EIP712Transfers", version = "1"
    constructor() EIP712("EIP712Transfers", "1") {}

    struct Transfer {
        address from;
        address to;
        uint256 amount;
        uint256 nonce;
        uint256 deadline; // unix timestamp
    }

    // typehash do struct (fixo)
    bytes32 private constant TRANSFER_TYPEHASH =
        keccak256(
            "Transfer(address from,address to,uint256 amount,uint256 nonce,uint256 deadline)"
        );

    mapping(address => uint256) public nonces;
    mapping(address => uint256) public balances;

    event Executed(address indexed from, address indexed to, uint256 amount);

    // helper: calcula o structHash do EIP-712
    function _hashTransfer(Transfer calldata t) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                TRANSFER_TYPEHASH,
                t.from,
                t.to,
                t.amount,
                t.nonce,
                t.deadline
            )
        );
    }

    // retorna o digest EIP-712 (domainSeparator + structHash)
    function getTypedDataHash(Transfer calldata t) external view returns (bytes32) {
        return _hashTypedDataV4(_hashTransfer(t));
    }

    // verifica assinatura e executa a ação (exemplo: mover “saldos” internos)
    function execute(Transfer calldata t, bytes calldata signature) external {
        require(block.timestamp <= t.deadline, "expired");
        require(t.nonce == nonces[t.from], "bad nonce");

        // digest padronizado EIP-712
        bytes32 digest = _hashTypedDataV4(_hashTransfer(t));
        address signer = ECDSA.recover(digest, signature);
        require(signer == t.from, "invalid signature");

        // lógica de "transfer": aqui está simples, ajusta saldos internos
        require(balances[t.from] >= t.amount, "insufficient");
        balances[t.from] -= t.amount;
        balances[t.to] += t.amount;

        nonces[t.from] += 1;
        emit Executed(t.from, t.to, t.amount);
    }

    // utilitário para popular saldos (ex.: em testes)
    function faucet(address to, uint256 amount) external {
        balances[to] += amount;
    }
}
