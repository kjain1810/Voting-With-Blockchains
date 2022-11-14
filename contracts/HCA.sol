// SPDX-License-Identifier: MIT
pragma solidity >=0.8.16;
pragma experimental ABIEncoderV2;

import {VotingBase} from "./VotingBase.sol";

contract HCA_Elections is VotingBase {
    uint8 private numDummyCoins;
    bool private dummyCoinValueSet = false;

    constructor() VotingBase() {}

    mapping(uint64 => uint64) dummyCoins;
    mapping(uint64 => uint64) dummyCoinStatus;
    mapping(uint64 => bool) voteCoins;
    mapping(uint64 => uint256) voteCoinIndex;
    mapping(uint64 => uint256) voteCoinKey;
    mapping(uint64 => uint64) votesRecved;

    function setDummyCoinValue(uint8 val) public {
        require(
            electionStage != ElectionStage.RUNNING,
            "Election already underway"
        );
        numDummyCoins = val;
        dummyCoinValueSet = true;
    }

    function getDummyCoinValue() public view returns (uint64) {
        require(dummyCoinValueSet == true, "Value not set yet!");
        return numDummyCoins;
    }

    function allotCoins() private {
        for (uint64 i = 1; i <= numVoters; i++) {
            dummyCoins[i] = numDummyCoins;
            dummyCoinStatus[i] = 0;
            voteCoins[i] = true;
            voteCoinIndex[i] = random(numDummyCoins, 0);
            emit CoinsAllotted(i, dummyCoins[i] + 1);
            voteCoinKey[i] = random(0xffffffffffff, 0);
            bytes32 voteCoinIndexEncrypted = keccak256(
                abi.encodePacked(voteCoinIndex[i] + voteCoinKey[i])
            );
            bytes32 keyEncrypted = keccak256(abi.encodePacked(voteCoinKey[i]));
            emit VoteCoinEncrypted(i, voteCoinIndexEncrypted, keyEncrypted);
        }
    }

    function startElection() public override startElectionModifier {
        require(
            dummyCoinValueSet == true,
            "Set number of dummy coin for each voter"
        );
        // require(electionStage == ElectionStage.AWAITING_VOTER_LIST); // This is done as part of modifier
        allotCoins();
        for (uint64 i = 1; i <= numCandidates; i++) {
            votesRecved[i] = 0;
        }
        electionStage = ElectionStage.RUNNING;
        emit ElectionStarted();
    }

    function getVoteCoinIndex(uint64 voterID) public view returns (uint256) {
        require(voterID <= numVoters, "Invalid ID!");
        require(msg.sender == indexToVoter[voterID].addr, "Bad request!");
        require(electionStage == ElectionStage.RUNNING, "No election running!");
        return voteCoinIndex[voterID];
    }

    function coinsLeft(uint64 voterID) public view returns (uint64) {
        if (voteCoins[voterID]) return 1 + dummyCoins[voterID];
        return dummyCoins[voterID];
    }

    function sendCoin(
        uint64 voterID,
        uint64 candidateID,
        uint8 coinIndex
    ) public {
        require(
            electionStage == ElectionStage.RUNNING,
            "Election not underway!"
        );
        require(voterID <= numVoters, "Invalid voter ID!");
        require(voterID > 0, "Invalid voter ID!");
        require(candidateID <= numCandidates, "Invalid candidate ID!");
        require(candidateID > 0, "Invalid voter ID!");
        require(msg.sender == indexToVoter[voterID].addr, "Bad request!");
        require(coinIndex <= numDummyCoins + 1, "Invalid coin index!");
        if (coinIndex == voteCoinIndex[voterID]) {
            require(
                voteCoins[voterID] == true,
                "Coin already spent! (vote coin)"
            );
            voteCoins[voterID] = false;
            votesRecved[candidateID] += 1;
        } else {
            require(
                (dummyCoinStatus[voterID] & (1 << coinIndex)) == 0,
                "Coin already spent! (dummy coin)"
            );
            dummyCoinStatus[voterID] =
                dummyCoinStatus[voterID] |
                uint64(1 << coinIndex);
            dummyCoins[voterID] -= 1;
        }
        emit CoinSent(voterID, candidateID, coinIndex);
    }

    function startReveal() public override {
        electionStage = ElectionStage.REVEALING;
    }

    function endElection() public override endElectionModifier {
        for (uint64 i = 1; i <= numVoters; i++) {
            emit VoteCoinIndexReveal(i, voteCoinIndex[i], voteCoinKey[i]);
        }
        for (uint64 i = 1; i <= numCandidates; i++) {
            emit DeclareVotes(i, votesRecved[i]);
        }
        electionStage = ElectionStage.NOT_RUNNING;
    }

    function getWinner() public view override returns (uint64) {
        uint64 maxVotes = 0;
        uint64 winnerID = 0;
        for (uint64 i = 1; i <= numCandidates; i++) {
            if (votesRecved[i] > maxVotes) {
                maxVotes = votesRecved[i];
                winnerID = i;
            }
        }
        return winnerID;
    }

    function clearData() public override clearDataModifier {
        for (uint64 i = 1; i <= numVoters; i++) {
            delete (dummyCoins[i]);
            delete (dummyCoinStatus[i]);
            delete (voteCoins[i]);
            delete (voteCoinIndex[i]);
            delete (voteCoinKey[i]);
        }
        for (uint64 i = 1; i <= numCandidates; i++) {
            delete (votesRecved[i]);
        }
        dummyCoinValueSet = false;
    }

    event ElectionStarted();
    event CoinsAllotted(uint64 voterID, uint64 numCoins);
    event VoteCoinEncrypted(
        uint64 voterID,
        bytes32 voteCoinIndexEncrypted,
        bytes32 keyEncrypted
    );
    event CoinSent(uint64 voterID, uint64 candidateID, uint64 coinIndex);
    event VoteCoinIndexReveal(
        uint64 voterID,
        uint256 voteCoinIndex,
        uint256 voteCoinKey
    );
    event DeclareVotes(uint64 candidateID, uint64 numVotes);
}
