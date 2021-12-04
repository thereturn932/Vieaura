const main = async () => {
  /**
   * Contract address for Token on local fork is 0xe8D2A1E88c91DCd5433208d4152Cc4F399a7e91d
   * 
   * 
   * 
   */
    const waveContractFactory = await hre.ethers.getContractFactory('VieauraToken');
    const waveContract = await waveContractFactory.deploy();
    await waveContract.deployed();
    console.log("Contract deployed to:", waveContract.address);
    console.log("Minting...");
    await waveContract.mint("0xdd2fd4581271e230360230f9337d5c0430bf44c0",hre.ethers.utils.parseEther('0.1'));
    console.log("Minted...");
    const balance = await waveContract.balanceOf("0xdd2fd4581271e230360230f9337d5c0430bf44c0");
    console.log("User balance is", hre.ethers.utils.formatEther(balance));

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