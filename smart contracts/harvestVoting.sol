pragma solidity ^0.4.6;
// We have to specify what version of compiler this code will compile with

contract Voting {
    /* mapping field below is equivalent to an associative array or hash.
    The key of the mapping is candidate name stored as type bytes32 and value is
    an unsigned integer to store the vote count
    */
    event onVote(bool opinion, address sender);
    event onVotingEnded(bool consensus, bool opinion);

    mapping (bool => uint64) public votesReceived;

    bool[] public opinionList;
    bool[10] public individualVotes;
    bool[10] public bannedRobots;
    uint64 totalVotes;
    uint64 maxVotes;
    bool maxOpinion;
    bool consensus;
    uint64 numRounds;
    uint32[10] public byzantineCount;

    /* This is the constructor which will be called once when you
    deploy the contract to the blockchain. When we deploy the contract,
    we will pass an array of candidates who will be contesting in the election
    */
    function Voting(bool[] opinionNames) public {
        opinionList = opinionNames;
    }

    function votingRoundEnded() public {
        consensusReached();
        numRounds += 1;
        for(uint8 i = 0; i < opinionList.length; i++) {
            votesReceived[opinionList[i]] = 0;
            totalVotes = 0;
        }

        for(uint8 j = 0; j < 10; j++) {
            if (individualVotes[j] != maxOpinion) {
                byzantineCount[j] += 1;
            }

            if (numRounds > 4){
                if (byzantineCount[j] > numRounds/2) {
                    bannedRobots[j] = true;
                }
            }
        }
    }

    function seeBanned() view public returns (uint32[10], bool[10], uint64) {
        return(byzantineCount, bannedRobots, numRounds);
    }

    function countVotes() view public returns (bool, uint64, uint64) {
        maxVotes = 0;
        for(uint i = 0; i < opinionList.length; i++) {
            if (votesReceived[opinionList[i]] > maxVotes) {
                maxVotes = votesReceived[opinionList[i]];
                maxOpinion = opinionList[i];
            }
        }
        return(maxOpinion, maxVotes, totalVotes);
    }

    function consensusReached() view public returns (bool, bool) {
        countVotes();
        if (maxVotes == totalVotes) {
            consensus = true;
            onVotingEnded(true, maxOpinion);
        } else {
            consensus = false;
            onVotingEnded(false, maxOpinion);
        }
        return(consensus, maxOpinion);
    }

    // This function returns the total votes a candidate has received so far
    function totalVotesFor(bool opinion) view public returns (uint64) {
        return votesReceived[opinion];
    }

    // This function increments the vote count for the specified candidate. This
    // is equivalent to casting a vote
    function voteForOpinion(bool opinion, uint8 sender) public {
        onVote(opinion, sender);
        if (!bannedRobots[sender]) {
            votesReceived[opinion] += 1;
            individualVotes[sender] = opinion;
            totalVotes += 1;
        }
    }

    function initialise() {
        numRounds = 0;
        consensus  =false;
        for(uint8 i = 0; i < 10; i++) {
            bannedRobots[i] = false;
            byzantineCount[i] = 0;
        }

    }
}
