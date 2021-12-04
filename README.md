### VIEAURA Challenge

This projects puts requested amount of DAI into 3pool then LP tokens from pool to LiquidityGauge.

In this project Hardhat is used.

To install hardhat

```shell
npm install --save-dev hardhat
```
To install waffle & ethers

```shell
npm install --save-dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
```

To test this project mainnet should be forked by (Hardnet caches data when forked, block number is to not download forked data everytime new block added)
Instead of <key> an alchemy account should be created and key of the account should be written.

```shell
npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/<key> --fork-block-number 13734775
```


TO-DO
⋅⋅*Detailed Explanations for function
⋅⋅*Appropriate Testing
⋅⋅*Events will be added