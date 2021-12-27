### VIEAURA Challenge

This projects puts requested amount of DAI into 3pool then LP tokens from pool to LiquidityGauge. 

To convert CRV tokens minted from gauge Uniswap is used.

In this project Hardhat is used.

To install hardhat

```shell
npm install --save-dev hardhat
```
To install waffle & ethers

```shell
npm install --save-dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
```

To test this project mainnet should be forked (Hardnet caches data when forked, block number is to not download forked data everytime new block added).
Instead of \<key\> an alchemy account should be created and key of the account should be written in `.env` file (`.env`should be created in root folder of project).

Can be tested by running

```shell
npx hardhat install
npx hardhat test
```


TO-DO:

* Improve safety of contract
* There might be security issues in harvesting part.
