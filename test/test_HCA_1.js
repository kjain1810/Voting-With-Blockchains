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

    it("Do coin allocation", async() => {
        const instance = await testcontract.deployed();
        await instance.setDummyCoinValue(5);
        let value = await instance.getDummyCoinValue();
        assert.equal(value, 5);
        await instance.startElection();
        value = await instance.getElectionStatus();
        assert.equal(value, 3);
        // get vote coint index of all voters
        const account3VoteCoinIndex = await instance.getVoteCoinIndex(1, {from: accounts[3]});
        const account4VoteCoinIndex = await instance.getVoteCoinIndex(2, {from: accounts[4]});
        const account5VoteCoinIndex = await instance.getVoteCoinIndex(3, {from: accounts[5]});
        console.log(account3VoteCoinIndex);
        console.log(account4VoteCoinIndex);
        console.log(account5VoteCoinIndex);
        assert(account3VoteCoinIndex <= 5);
        assert(account4VoteCoinIndex <= 5);
        assert(account5VoteCoinIndex <= 5);
    });

    it("Send votes", async() => {
        const instance = await testcontract.deployed();
        // send coins from each voter to some of the candidates
        // VOTER 1
        await instance.sendCoin(1, 2, 0, {from: accounts[3]});
        await instance.sendCoin(1, 1, 1, {from: accounts[3]});
        await instance.sendCoin(1, 2, 2, {from: accounts[3]});
        value = await instance.coinsLeft(1);
        assert.equal(value, 3);
        await instance.sendCoin(1, 3, 3, {from: accounts[3]});
        await instance.sendCoin(1, 1, 4, {from: accounts[3]});
        await instance.sendCoin(1, 2, 5, {from: accounts[3]});

        // VOTER 2
        await instance.sendCoin(2, 3, 0, {from: accounts[4]});
        await instance.sendCoin(2, 2, 1, {from: accounts[4]});
        await instance.sendCoin(2, 1, 2, {from: accounts[4]});
        await instance.sendCoin(2, 3, 3, {from: accounts[4]});
        value = await instance.coinsLeft(2);
        assert.equal(value, 2);
        await instance.sendCoin(2, 1, 4, {from: accounts[4]});
        await instance.sendCoin(2, 2, 5, {from: accounts[4]});

        // VOTER 3
        value = await instance.coinsLeft(3);
        assert.equal(value, 6);
        await instance.sendCoin(3, 1, 0, {from: accounts[5]});
        await instance.sendCoin(3, 2, 1, {from: accounts[5]});
        await instance.sendCoin(3, 2, 2, {from: accounts[5]});
        await instance.sendCoin(3, 3, 3, {from: accounts[5]});
        await instance.sendCoin(3, 1, 4, {from: accounts[5]});
        await instance.sendCoin(3, 3, 5, {from: accounts[5]});
        value = await instance.coinsLeft(3);
        assert.equal(value,  0);
    });

    it("Get winner and clear data", async() => {
        const instance = await testcontract.deployed();
        // get vote coint index of all voters
        const account3VoteCoinIndex = await instance.getVoteCoinIndex(1, {from: accounts[3]});
        const account4VoteCoinIndex = await instance.getVoteCoinIndex(2, {from: accounts[4]});
        const account5VoteCoinIndex = await instance.getVoteCoinIndex(3, {from: accounts[5]});
        await instance.startReveal();
        await instance.endElection();
        value = await instance.getWinner();
        console.log("Winner is: ", value);
        console.log("Vote coin indices were: [", account3VoteCoinIndex, ", ", account4VoteCoinIndex, ", ",account5VoteCoinIndex, "]");
        await instance.clearData();
    });
});