// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {EIP712Transfers} from "../src/EIP712Transfers.sol";
import {console} from "forge-std/console.sol";

contract EIP712TransfersTest is Test {
    EIP712Transfers c;
    uint256 pk; address alice; address bob;

    function setUp() external {
        c = new EIP712Transfers();
        (alice, pk) = makeAddrAndKey("ALICE");
        (bob, ) = makeAddrAndKey("BOB");
        c.faucet(alice, 100 ether);
    }

    function testExecute() external {
        console.log("\n\n\n----alice: %s\n\n\n", alice);
        EIP712Transfers.Transfer memory t = EIP712Transfers.Transfer({
            from: alice,
            to: bob,
            amount: 5 ether,
            nonce: c.nonces(alice),
            deadline: block.timestamp + 1 hours
        });

        bytes32 digest = c.getTypedDataHash(t);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.prank(bob); // qualquer um pode relayer (meta-tx style)
        c.execute(t, sig);

        assertEq(c.balances(alice), 95 ether);
        assertEq(c.balances(bob), 5 ether);
        assertEq(c.nonces(alice), 1);
    }
}
