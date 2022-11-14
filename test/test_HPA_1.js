const testcontract = artifacts.require("HPA_Elections");

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

    it("Do account allocation", async() => {
        const instance = await testcontract.deployed();
        const V = await instance.getNumberOfVoters();
        const A = 0.1;
        const B = 0.1;
        const X = Math.sqrt((A * V  * ( A * V - 1)) / (2 * B));
        // const intX = Math.ceil(X) + 1;
        const intX = 10;
        await instance.setNumberOfAccounts(10);
        let value = await instance.getNumberOfAccounts();
        assert.equal(value, intX);
    });

    it("Get account numbers", async() => {
        const instance = await testcontract.deployed();
        await instance.startElection();
        value = await instance.getElectionStatus();
        assert.equal(value, 3);

        const firstVoterAccounts = [];
        const secondVoterAccounts = [];
        const thirdVoterAccounts = [];
        const X = await instance.getNumberOfAccounts();
        firstVoterAccounts.push(await instance.getCandidateAccount(1, 1, {from: accounts[3]}));
        firstVoterAccounts.push(await instance.getCandidateAccount(1, 2, {from: accounts[3]}));
        firstVoterAccounts.push(await instance.getCandidateAccount(1, 3, {from: accounts[3]}));
        secondVoterAccounts.push(await instance.getCandidateAccount(2, 1, {from: accounts[4]}));
        secondVoterAccounts.push(await instance.getCandidateAccount(2, 2, {from: accounts[4]}));
        secondVoterAccounts.push(await instance.getCandidateAccount(2, 3, {from: accounts[4]}));
        thirdVoterAccounts.push(await instance.getCandidateAccount(3, 1, {from: accounts[5]}));
        thirdVoterAccounts.push(await instance.getCandidateAccount(3, 2, {from: accounts[5]}));
        thirdVoterAccounts.push(await instance.getCandidateAccount(3, 3, {from: accounts[5]}));
        console.log(firstVoterAccounts);
        console.log(secondVoterAccounts);
        console.log(thirdVoterAccounts);
        for(let i = 0; i < 3; i++) {
            assert(firstVoterAccounts[i] < X * 3);
            assert(secondVoterAccounts[i] < X * 3);
            assert(thirdVoterAccounts[i] < X * 3);
        }
    });

    it("Give votes", async() => {
        const instance = await testcontract.deployed();
        const voterOneCandidateOne = await instance.getCandidateAccount(1, 1, {from: accounts[3]});
        const voterTwoCandidateOne = await instance.getCandidateAccount(2, 1, {from: accounts[4]});
        const voterThreeCandidateThree = await instance.getCandidateAccount(3, 3, {from: accounts[5]});
        await instance.sendVote(1, voterOneCandidateOne, {from: accounts[3]});
        await instance.sendVote(2, voterTwoCandidateOne, {from: accounts[4]});
        await instance.sendVote(3, voterThreeCandidateThree, {from: accounts[5]});
    });

    it("Reveal result", async() => {
        const instance = await testcontract.deployed();
        await instance.startReveal();
        await instance.endElection();
        value = await instance.getWinner();
        console.log("Winner is: ", value);

    });
});