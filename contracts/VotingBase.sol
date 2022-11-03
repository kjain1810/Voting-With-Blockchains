// SPDX-License-Identifier: MIT
pragma solidity >=0.8.16;
pragma experimental ABIEncoderV2;

contract VotingBase {
    enum ElectionStage {
        NOT_RUNNING,
        AWAITING_CANDIDATE_LIST,
        AWAITING_VOTER_LIST,
        RUNNING
    }

    enum VoterStage {
        REGISTERED,
        SIGNED_UP,
        VOTED
    }

    struct Candidate {
        address addr;
        uint64 votes;
        uint64 index;
    }

    struct Voter {
        address addr;
        uint64 index;
        VoterStage stage;
    }

    mapping(uint64 => Candidate) indexToCandidate;
    mapping(uint64 => Voter) indexToVoter;

    uint64 private numCandidates;
    uint64 private numVoters;
    address payable public owner;
    ElectionStage public electionStage;

    constructor() {
        owner = payable(msg.sender);
        numCandidates = 0;
        numVoters = 0;
        electionStage = ElectionStage.NOT_RUNNING;
    }
}
