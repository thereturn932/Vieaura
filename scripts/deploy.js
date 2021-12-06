const { ethers } = require("hardhat");
const hre = require("hardhat");

const main = async () => {
  const viaTokenFactory = await hre.ethers.getContractFactory('VieauraToken');

    /// Deploy Vieaura contract
    const viaToken = await viaTokenFactory.deploy();
    await viaToken.deployed();
    console.log("Token contract deployed to:", viaToken.address);
    

    /// Deploy Vieaura contract
    const VieauraContractFactory = await hre.ethers.getContractFactory('Vieaura');
    const VieauraContract = await VieauraContractFactory.deploy();
    await VieauraContract.deployed({
      value: hre.ethers.utils.parseEther('1'),
    });


    console.log("Vieaura contract deployed to:", VieauraContract.address);

    await viaToken.AddMinter(VieauraContract.address);
    console.log("Contract is added as minter");

    await VieauraContract.ChangeVIATokenAddress(viaToken.address);
    console.log("VIAToken contract address changed in Vieaura");


};
  
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }


};
  
runMain();