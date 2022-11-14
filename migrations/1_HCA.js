const HCA_Elections = artifacts.require("HCA_Elections");

module.exports = function (deployer) {
    deployer.deploy(HCA_Elections);
};
