const testcontract = artifacts.require("VotingBase");

contract("testcontract", (accounts) => {
    it("Start elections", async() => {
        const instance = await testcontract.deployed();
        await instance.acceptCandidates();
        const value = instance.getElectionStatus();
        assert.equal(value, 1);
        await instance.addCandidate(accounts[0]);
        await instance.addCandidate(accounts[1]);
        await instance.addCandidate(accounts[2]);
        value = await instance.getNumberOfCandidates();
        assert.equal(value, 3);
        await instance.acceptVoters();
        value = instance.getElectionStatus();
        assert.equal(value, 2);
        await instance.addVoter(accounts[3]);
        await instance.addVoter(accounts[4]);
        await instance.addVoter(accounts[5]);
        value = await instance.getNumberOfVoters();
        assert.equal(value, 3);
    });
    it("Start voting", async() => {
        const instance = await testcontract.deployed();
        await instance.startElection();
        value = instance.getElectionStatus();
        assert.equal(value, 3);
    });
});