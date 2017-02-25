var Weather = artifacts.require("./Weather.sol");
module.exports = function(deployer) {
  deployer.deploy(Weather);
};
