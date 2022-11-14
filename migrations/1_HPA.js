const HPA_Elections = artifacts.require("HPA_Elections");

module.exports = function (deployer) {
    deployer.deploy(HPA_Elections);
};
