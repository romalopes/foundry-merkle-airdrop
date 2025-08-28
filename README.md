## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

```shell
$ foundryup
$ forge init
```

```shell
$ forge install openzeppelin/openzeppelin-contracts
$ forge install chainaccelorg/foundry-devops
```

Using Murky to create the MerkleTree

```shell
$ forge install dmfxyz/murky

$ forge script ./script/GenerateInput.s.sol:GenerateInput
$ forge script ./script/MakeMerkle.s.sol:MakeMerkle
$ forge install cyfrin/foundry-devops
forge install dmfxyz/murky
```

call : $ make deploy-anvil
0: contract MerkleAirdrop 0x59F2f1fCfE2474fD5F0b9BA1E73ca90b143Eb8d0
1: contract BagelToken 0xbCF26943C0197d2eE0E5D05c716Be60cc2761508

Contract Address: 0x8464135c8F25Da09e49BC8782676a84730C318bC
Contract Address: 0x71C95911E9a5D330f4D621842EC243EE1343292e

## Call the MerkleAirdro.getMessageHash to get the data to sign.

###########################
$ cast call MerkelAirdropAddress "getMessageHash(address, uint256)" USER-Address 25000000000000000000 --rpc-url http://localhost:8545
$ cast call 0x59F2f1fCfE2474fD5F0b9BA1E73ca90b143Eb8d0 "getMessageHash(address, uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545
Result: signature 0x2fd43a60b09dd9a095aa4dd338d9347971b4bd6391ba062b236167c6ad7dc596

cast wallet sign --no-hash RESULT-SIGNATURE --private-key ANVIL_PRIVATE_KEY
$ cast wallet sign --no-hash 0x2fd43a60b09dd9a095aa4dd338d9347971b4bd6391ba062b236167c6ad7dc596 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
Result: 0xa64030c878c0a9deb859cf55f71539aeba64e79018965bc7f231aca4a6b441bf4828d7c95b73649ef57be12b9a6bba8703a6e8a6afc9190a3e5280ea8a69a0091c
############################

cast call 0x71C95911E9a5D330f4D621842EC243EE1343292e "getMessageHash(address, uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545
Result signature: 0x4c054dd4e03cdd0893d36d2f51031c773403418fdf518da8ebd1f64b930135f4

$ cast wallet sign --no-hash 0x4c054dd4e03cdd0893d36d2f51031c773403418fdf518da8ebd1f64b930135f4 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
Result: 0x6a631769dc1e9517a179a8cd850e006e5363b0e6eea5216d098dfe12270de98525b8ba18540a4ebc4ccf45d6e6cbd8f6c56b645a3dc1d97146a499930dc0af511c

33333333.

Go to Interact.s.sol
Add the result in Signature without 0x
Split signature using assembly

To deploy and claim in Anvil
$ forge script script/Interact.s.sol:ClaimAirdrop --rpc-url http://localhost:8545 private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

$ cast call TOKEN_CONTRACT_ADDRESS "balanceOf(address)" PARAMETER_ADDRESS

$ cast to-dec hexadecimal
