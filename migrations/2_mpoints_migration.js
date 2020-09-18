const Mpoints = artifacts.require("MpointsToken");

module.exports = function(deployer) {
  deployer.deploy(Mpoints);
};
