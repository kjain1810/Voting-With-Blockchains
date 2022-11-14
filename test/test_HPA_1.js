const testcontract = artifacts.require("HCA_Elections");

contract("testcontract", (accounts) => {
    it ("Clear data", async() => {
        const instance = await testcontract.deployed();
        await instance.clearData();
    });
    
    it("Start elections", async() => {
        const instance = await testcontract.deployed();
        await instance.acceptCandidates();
        let value = await instance.getElectionStatus();
        assert.equal(value, 1);
        await instance.addCandidate(accounts[0]);
        await instance.addCandidate(accounts[1]);
        await instance.addCandidate(accounts[2]);
        value = await instance.getNumberOfCandidates();
        assert.equal(value, 3);
        await instance.acceptVoters();
        value = await instance.getElectionStatus();
        assert.equal(value, 2);
        await instance.addVoter(accounts[3]);
        await instance.addVoter(accounts[4]);
        await instance.addVoter(accounts[5]);
        value = await instance.getNumberOfVoters();
        assert.equal(value, 3);
    });
});