const VotingBase = artifacts.require("VotingBase");

module.exports = function (deployer) {
    deployer.deploy(VotingBase);
};
