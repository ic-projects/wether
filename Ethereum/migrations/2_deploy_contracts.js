var Help = artifacts.require("./Help.sol");
var Oracle = artifacts.require("./usingOraclize.sol");
var Weather = artifacts.require("./Weather.sol");


module.exports = function(deployer) {
  deployer.deploy(Help);
  deployer.deploy(Oracle);
  deployer.deploy(Weather);
};
