const { expect } = require("chai");
const { BigNumber, ethers } = require("hardhat");

let DAI_ABI;
let daiAddress;
let viaTokenFactory;
let viaToken;
let VieauraContractFactory;
let VieauraContract;

describe("Vieaura Challenge", async function () {
  before( async function () {
    DAI_ABI = [{"inputs":[{"internalType":"uint256","name":"chainId_","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"src","type":"address"},{"indexed":true,"internalType":"address","name":"guy","type":"address"},{"indexed":false,"internalType":"uint256","name":"wad","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":true,"inputs":[{"indexed":true,"internalType":"bytes4","name":"sig","type":"bytes4"},{"indexed":true,"internalType":"address","name":"usr","type":"address"},{"indexed":true,"internalType":"bytes32","name":"arg1","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"arg2","type":"bytes32"},{"indexed":false,"internalType":"bytes","name":"data","type":"bytes"}],"name":"LogNote","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"src","type":"address"},{"indexed":true,"internalType":"address","name":"dst","type":"address"},{"indexed":false,"internalType":"uint256","name":"wad","type":"uint256"}],"name":"Transfer","type":"event"},{"constant":true,"inputs":[],"name":"DOMAIN_SEPARATOR","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"PERMIT_TYPEHASH","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"usr","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"usr","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"burn","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"guy","type":"address"}],"name":"deny","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"usr","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"mint","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"src","type":"address"},{"internalType":"address","name":"dst","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"move","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"nonces","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"holder","type":"address"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"expiry","type":"uint256"},{"internalType":"bool","name":"allowed","type":"bool"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"permit","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"usr","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"pull","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"usr","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"push","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"guy","type":"address"}],"name":"rely","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"dst","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"src","type":"address"},{"internalType":"address","name":"dst","type":"address"},{"internalType":"uint256","name":"wad","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"version","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"wards","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}];
    daiAddress = "0x6b175474e89094c44da98b954eedeac495271d0f"



    viaTokenFactory = await hre.ethers.getContractFactory('VieauraToken');
    viaToken = await viaTokenFactory.deploy();
    await viaToken.deployed();
    console.log("Token contract deployed to:", viaToken.address);

    VieauraContractFactory = await hre.ethers.getContractFactory('Vieaura');
    VieauraContract = await VieauraContractFactory.deploy();
    await VieauraContract.deployed({
      value: hre.ethers.utils.parseEther('1'),
    });
    console.log("Vieaura contract deployed to:", VieauraContract.address);

    await viaToken.AddMinter(VieauraContract.address);
    console.log("Contract is added as minter");

    await VieauraContract.ChangeVIATokenAddress(viaToken.address);
    console.log("VIAToken contract address changed in Vieaura");
  })

  it("first deposits money then harvests then withdraws all", async function () {
    let accountToInpersonate = "0x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503";
    await hre.network.provider.request({method: 'hardhat_impersonateAccount', params: [accountToInpersonate]})
    const signer = await ethers.getSigner(accountToInpersonate)

    userAddress = "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f";
    const daiContract = new ethers.Contract(daiAddress, DAI_ABI, signer);
    let daiBalance = await daiContract.balanceOf(accountToInpersonate);
    console.log("Whale dai balance", hre.ethers.utils.formatEther(daiBalance))
    await daiContract.transfer(userAddress,daiBalance);
    console.log("Whale dai balance transfered to 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f")
    const anEthersProvider = new ethers.providers.Web3Provider(network.provider)
    const VIAuser = new ethers.Wallet('0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97', anEthersProvider);
    daiBalance = await daiContract.balanceOf(userAddress);
    console.log("User dai balance", hre.ethers.utils.formatEther(daiBalance))

    await daiContract.connect(VIAuser).approve(VieauraContract.address, hre.ethers.utils.parseEther('1000'))
    console.log("Approved 1000 DAI");

    await VieauraContract.connect(VIAuser).deposit(hre.ethers.utils.parseEther('1000'));

    console.log("Deposited 1000 DAI");
    daiBalance = await daiContract.balanceOf(userAddress);
    console.log("New user DAI balance", hre.ethers.utils.formatEther(daiBalance));
    let viaBalance = await viaToken.balanceOf(userAddress);
    console.log("New user VIA balance", hre.ethers.utils.formatEther(viaBalance));

    await VieauraContract.connect(VIAuser).harvest()
    console.log("User harvested CRV but since on a test chain 0 tokens to return");
    daiBalance = await daiContract.balanceOf(userAddress);
    console.log("New user DAI balance", hre.ethers.utils.formatEther(daiBalance));
    viaBalance = await viaToken.balanceOf(userAddress);
    console.log("New user VIA balance", hre.ethers.utils.formatEther(viaBalance));
    
    console.log("Withdraw all")
    await viaToken.connect(VIAuser).approve(VieauraContract.address, viaBalance);
    await VieauraContract.connect(VIAuser).withdraw(viaBalance);
    daiBalance = await daiContract.balanceOf(userAddress);
    console.log("New user DAI balance", hre.ethers.utils.formatEther(daiBalance));
    viaBalance = await viaToken.balanceOf(userAddress);
    console.log("New user VIA balance", hre.ethers.utils.formatEther(viaBalance));
    });

  it("reverts because of insufficient DAI balance", async function () {
    //User address
    let userAddress = "0xbda5747bfd65f08deb54cb465eb87d40e51b197e";
    const anEthersProvider = new ethers.providers.Web3Provider(network.provider)
    const VIAuser = new ethers.Wallet('0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd', anEthersProvider);

    const daiContract = new ethers.Contract(daiAddress, DAI_ABI, VIAuser);
    let daiBalance = await daiContract.balanceOf(userAddress);
    console.log("User dai balance", hre.ethers.utils.formatEther(daiBalance))

    await daiContract.connect(VIAuser).approve(VieauraContract.address, hre.ethers.utils.parseEther('1000'))
    console.log("Approved 1000 DAI");
    expect(await VieauraContract.connect(VIAuser).deposit(hre.ethers.utils.parseEther('1000'))).to.be.revertedWith('Dai/insufficient-balance');
    console.log("Could not deposit DAI");
    });

it("reverts because of tries to deposit more than DAI allowance", async function () {
  //User address
  let userAddress = "0xbda5747bfd65f08deb54cb465eb87d40e51b197e";
  const anEthersProvider = new ethers.providers.Web3Provider(network.provider)
  const VIAuser = new ethers.Wallet('0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd', anEthersProvider);
  
  const daiContract = new ethers.Contract(daiAddress, DAI_ABI, VIAuser);
  let daiBalance = await daiContract.balanceOf(userAddress);
  console.log("User dai balance", hre.ethers.utils.formatEther(daiBalance))
  
  await daiContract.connect(VIAuser).approve(VieauraContract.address, hre.ethers.utils.parseEther('1000'))
  console.log("Approved 1000 DAI");
  expect(await VieauraContract.connect(VIAuser).deposit(hre.ethers.utils.parseEther('2000'))).to.be.reverted;
  console.log("Could not deposit DAI");
  });

  it(" returns exchange rate between DAI and LP", async function () {
    //User address
    
    let exchangeRate = await VieauraContract.exchangeRate();
    console.log("Current exchange rate is: ", hre.ethers.utils.formatEther(exchangeRate));
    });
});
