// SPDX-License-Identifier: MIT
pragma solidity >=0.8.16;
pragma experimental ABIEncoderV2;

contract VotingBase {
    enum ElectionStage {
        NOT_RUNNING,
        AWAITING_CANDIDATE_LIST,
        AWAITING_VOTER_LIST,
        RUNNING,
        REVEALING
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
    mapping(uint64 => Voter) internal indexToVoter;

    uint64 internal numCandidates;
    uint64 internal numVoters;
    uint64 internal nonce;
    address payable public owner;
    ElectionStage public electionStage;

    constructor() {
        owner = payable(msg.sender);
        numCandidates = 0;
        numVoters = 0;
        electionStage = ElectionStage.NOT_RUNNING;
        nonce = 0;
    }

    function random(uint64 maxNumber, uint64 minNumber)
        internal
        returns (uint256 amount)
    {
        amount =
            uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
            ) %
            (maxNumber - minNumber);
        amount = amount + minNumber;
        nonce++;
        return amount;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function convert256to64(uint256 _a) internal pure returns (uint64) {
        return uint64(_a);
    }

    function addCandidate(address addr) public {
        require(
            electionStage == ElectionStage.AWAITING_CANDIDATE_LIST,
            "Not accepting candidates right now"
        );
        numCandidates++;
        indexToCandidate[numCandidates] = Candidate(addr, 0, numCandidates);
        emit CandidateAdded(numCandidates, addr);
    }

    function addVoter(address addr) public {
        require(
            electionStage == ElectionStage.AWAITING_VOTER_LIST,
            "Not accepting voters right now"
        );
        numVoters++;
        indexToVoter[numVoters] = Voter(addr, numVoters, VoterStage.REGISTERED);
        emit VoterAdded(numVoters, addr);
    }

    function getNumberOfCandidates() public view returns (uint64) {
        return numCandidates;
    }

    function getNumberOfVoters() public view returns (uint64) {
        return numVoters;
    }

    function acceptCandidates() public {
        require(
            electionStage == ElectionStage.NOT_RUNNING,
            "Election already running"
        );
        electionStage = ElectionStage.AWAITING_CANDIDATE_LIST;
        emit CandidateSignUpStart();
    }

    function acceptVoters() public {
        require(
            electionStage == ElectionStage.AWAITING_CANDIDATE_LIST,
            "Candidates not registered till now"
        );
        electionStage = ElectionStage.AWAITING_VOTER_LIST;
        emit VoterSignUpStart();
    }

    modifier startElectionModifier() {
        require(
            electionStage == ElectionStage.AWAITING_VOTER_LIST,
            "Voters not registered yet"
        );
        _;
    }

    modifier startRevealModifier() {
        require(
            electionStage == ElectionStage.RUNNING,
            "Election not running at the moment!"
        );
        _;
    }

    modifier endElectionModifier() {
        require(
            electionStage == ElectionStage.REVEALING,
            "Reveal not started yet!"
        );
        _;
    }

    modifier clearDataModifier() {
        require(
            electionStage == ElectionStage.NOT_RUNNING,
            "Election in progress!"
        );
        for (uint64 i = 1; i <= numVoters; i++) {
            delete (indexToVoter[i]);
        }
        for (uint64 i = 1; i <= numCandidates; i++) {
            delete (indexToCandidate[i]);
        }
        _;
        numCandidates = 0;
        numVoters = 0;
    }

    function startElection() public virtual startElectionModifier {}

    function startReveal() public virtual startRevealModifier {}

    function endElection() public virtual endElectionModifier {}

    function clearData() public virtual clearDataModifier {}

    function getWinner() public view virtual returns (uint64) {}

    function getElectionStatus() public view returns (uint256) {
        if (electionStage == ElectionStage.NOT_RUNNING) {
            return 0;
        } else if (electionStage == ElectionStage.AWAITING_CANDIDATE_LIST) {
            return 1;
        } else if (electionStage == ElectionStage.AWAITING_VOTER_LIST) {
            return 2;
        } else if (electionStage == ElectionStage.RUNNING) {
            return 3;
        } else if (electionStage == ElectionStage.REVEALING) {
            return 4;
        }
        return 10;
    }

    event CandidateSignUpStart();
    event CandidateAdded(uint64 candidateID, address candidateAddress);
    event VoterSignUpStart();
    event VoterAdded(uint64 voterID, address voterAddress);
    event DeclareVotes(uint64 candidateID, uint64 numVotes);
}
