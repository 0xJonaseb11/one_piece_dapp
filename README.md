# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

## `Contract deployment`

```sh
npx hardhat run scripts/deploy.js --network arbitrum_sepolia
```

## `Contract verification`

```sh
npx hardhat verify --constructor-args arguments.js <deployed_contract_address> --network arbitrum_sepolia
```

-------------------

## `Installing and enabling grapgh protocol`

```sh
cd client
```

```sh
# with npm
npm install -g @graphprotocol/graph-cli
# eith yarn
yarn global add @graphprotocol/graph-cli
```

### `Initialize the subgraph`

```sh
graph init --studio one_piece_dapp
```

### `Authenticate and deploy`

```sh
# authenticate in cli
graph auth --studio fd9731a523ad7fccab9c0617ccecb1f0
# Enter subgraph
cd one_piece_dapp
# build subgraph
graph codegen && graph build
```
