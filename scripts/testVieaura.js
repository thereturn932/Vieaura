const main = async () => {
  /**
   * Contract address for Token on local fork is 0xe8D2A1E88c91DCd5433208d4152Cc4F399a7e91d
   * 
   * 
   * 
   */

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x364d6D0333432C3Ac016Ca832fb8594A8cE43Ca6"],
    });
    const VieauraContractFactory = await hre.ethers.getContractFactory('Vieaura');
    const VieauraContract = await VieauraContractFactory.deploy();
    await VieauraContract.deployed();
    console.log("Contract deployed to:", VieauraContract.address);

    const exchangeRate = await VieauraContract.exchangeRate();
    console.log("Current Exchange Rate is", hre.ethers.utils.formatEther(exchangeRate));

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