const Wallet = artifacts.require("Wallet");

const ADDRESS1 = "0x3ad782973025b117231462f4bd9d1ca1beb40e7d";
const ADDRESS2 = "0x3ad782973025b117231462f4bd9d1ca1beb40e7d";

module.exports = function (deployer) {
  deployer.deploy(Wallet, [ADDRESS1, ADDRESS2], 2);
};
