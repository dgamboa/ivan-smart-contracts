const Capper = artifacts.require("CapperToken");

const TOKEN_NAME = "Capper";
const TOKEN_SYMBOL = "CPR";

module.exports = function (deployer) {
  deployer.deploy(Capper, TOKEN_NAME, TOKEN_SYMBOL, 1000);
};
