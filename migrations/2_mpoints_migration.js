const MpointsToken = artifacts.require("MpointsToken");
const MafiToken = artifacts.require("MafiToken");

module.exports = async (deployer) => {
  // get accounts
  const accounts = await web3.eth.getAccounts()

  // create Mafi token
  await deployer.deploy(MafiToken);
  const MAInstance = await MafiToken.deployed();

  // send 1000 tokens to account1, 2, 3, 4, 5
  await MAInstance.transfer(accounts[1], web3.utils.toBN(web3.utils.toWei('1000', 'ether')), { from: accounts[0] })
  await MAInstance.transfer(accounts[2], web3.utils.toBN(web3.utils.toWei('1000', 'ether')), { from: accounts[0] })
  await MAInstance.transfer(accounts[3], web3.utils.toBN(web3.utils.toWei('1000', 'ether')), { from: accounts[0] })
  await MAInstance.transfer(accounts[4], web3.utils.toBN(web3.utils.toWei('1000', 'ether')), { from: accounts[0] })
  await MAInstance.transfer(accounts[5], web3.utils.toBN(web3.utils.toWei('1000', 'ether')), { from: accounts[0] })

  // create Mpoints token for
  await deployer.deploy(MpointsToken);
  const MPInstance = await MpointsToken.deployed();

  // set mafi token address to staking contract
  await MPInstance.setMafiAddress(MPInstance.address, { from: accounts[0] })
};
