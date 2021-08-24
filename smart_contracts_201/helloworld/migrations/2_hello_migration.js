const hello = artifacts.require("Helloworld");

module.exports = function (deployer) {
  deployer.deploy(hello);
};
