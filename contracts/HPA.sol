// SPDX-License-Identifier: MIT
pragma solidity >=0.8.16;
pragma experimental ABIEncoderV2;

import {VotingBase} from "./VotingBase.sol";

contract HPA_Elections is VotingBase {
    uint256 private numAccounts;
    bool private numAccountsValueSet = false;

    constructor() VotingBase() {}

    mapping(uint256 => uint64) accountNumberToCandidate;
    mapping(uint64 => uint64) votesRecved;
    mapping(uint64 => uint256[]) accountsForCandidate;
    mapping(uint64 => uint256[]) accountsToVoters;

    function setNumberOfAccounts(uint256 X) public {
        require(
            electionStage != ElectionStage.REVEALING,
            "Election already underway"
        );
        numAccounts = X;
        numAccountsValueSet = true;
    }

    function getNumberOfAccounts() public view returns (uint256) {
        require(numAccountsValueSet == true, "Value not set");
        return numAccounts;
    }

    function allotAccounts() private {
        for (uint256 i = 0; i < numAccounts * numCandidates; i++) {
            accountNumberToCandidate[i] = convert256to64(
                random(numCandidates + 1, 1)
            );
            accountsForCandidate[accountNumberToCandidate[i]].push(i);
        }
        for (uint64 i = 1; i <= numVoters; i++) {
            for (uint64 j = 1; j <= numCandidates; j++) {
                require(accountsForCandidate[j].length > 0, uint2str(j));
                uint256 idx = random(
                    convert256to64(accountsForCandidate[j].length - 1),
                    0
                );
                accountsToVoters[i].push(accountsForCandidate[j][idx]);
            }
        }
        for (uint64 i = 1; i <= numCandidates; i++) {
            votesRecved[i] = 0;
        }
    }

    function startElection() public override startElectionModifier {
        require(
            numAccountsValueSet == true,
            "Set number of accounts for each candidate"
        );
        allotAccounts();
        electionStage = ElectionStage.RUNNING;
        emit AccountsAllotted();
    }

    function getCandidateAccount(uint64 voterID, uint64 candidateID)
        public
        view
        returns (uint256)
    {
        require(voterID <= numVoters, "Invalid voter ID");
        require(candidateID <= numVoters, "Invalid candidate ID");
        require(voterID > 0, "Invalid voter ID");
        require(candidateID > 0, "Invalid candidate ID");
        require(
            electionStage == ElectionStage.RUNNING,
            "Election not underway"
        );
        require(msg.sender == indexToVoter[voterID].addr, "Bad request");
        return accountsToVoters[voterID][candidateID - 1];
    }

    function sendVote(uint64 voterID, uint256 candidateAccount) public {
        require(voterID <= numVoters, "Invalid voter ID");
        require(voterID > 0, "Invalid voter ID");
        require(msg.sender == indexToVoter[voterID].addr, "Bad request");
        require(
            accountsToVoters[voterID][
                accountNumberToCandidate[candidateAccount] - 1
            ] == candidateAccount,
            "Account not allotted to you"
        );
        votesRecved[accountNumberToCandidate[candidateAccount]] += 1;
        emit VoteSend(voterID, candidateAccount);
    }

    function startReveal() public override {
        electionStage = ElectionStage.REVEALING;
    }

    function endElection() public override endElectionModifier {
        for (uint64 i = 0; i < numCandidates * numAccounts; i++) {
            emit RevealAccountToCandidate(i, accountNumberToCandidate[i]);
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
        for (uint64 i = 1; i <= numCandidates; i++) {
            delete (accountsForCandidate[i]);
            delete (votesRecved[i]);
        }
        for (uint64 i = 1; i <= numVoters; i++) {
            delete (accountsToVoters[i]);
        }
        for (uint256 i = 0; i < numCandidates * numAccounts; i++) {
            delete (accountNumberToCandidate[i]);
        }
        numAccountsValueSet = false;
    }

    event AccountsAllotted();
    event VoteSend(uint64 voterID, uint256 accountNumber);
    event RevealAccountToCandidate(uint256 accoutnNumber, uint64 candidateID);
}
