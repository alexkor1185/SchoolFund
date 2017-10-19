// Author: Alex
// Date: 2017-Oct-15, Ukraine

pragma solidity ^0.4.17;

// Parents can:
// 1. announce ballots (sets of proposals on how to spend the money
// 2. donate and vote (as a single step. Vote weight is proportional to the sum donated.)

//# https://github.com/ethereum/go-ethereum/wiki/Contract-Tutorial

/**
 * Mortal ancestor provides a valid way for the contract owner to destroy it to free Ethereum blockchain.
**/
contract Mortal
{
   address public owner;

   function Mortal() internal
   {
      owner = msg.sender;
   }

   function kill() internal
   {
      if (msg.sender == owner)
         selfdestruct(owner);
   }
}

// https://solidity.readthedocs.io/en/develop/introduction-to-smart-contracts.html
// https://solidity.readthedocs.io/en/develop/solidity-by-example.html

/// @title School Charity Fund
contract SchoolCharityFund is Mortal
{
   // all parents will be notified as soon as a new ballot is announced
   event EventNewBallotAnnounced(address[] beneficiaries, bytes32[] descriptions, uint[] costs);

   // Proposal on how to spend the money
   struct Proposal
   {
      address beneficiary; // globally unique ID of the proposal
      bytes32 description;
      uint cost;
      uint voteCount;
   }

   struct Ballot
   {
      // here is the list of all expenditure proposals
      mapping(address => Proposal) proposals;
      
      // remember proposal UIDs (there is no way to get mapping keys otherwise)
      address[] beneficiaries;

      // remember the votes
      mapping(address => address) votes;

      // remember voters (there is no way to get mapping keys otherwise)
      address[] voters;
      
      // will be set to 'now' automatically
      uint ballotStart;
      
      // not used yet
      uint biddingTime;
   }

   Ballot private ballot;

   // raise another ballot and notify the parents
   function InitNewBallot(address[] beneficiaries, bytes32[] descriptions, uint[] costs) public
   {
      // this is commented on purpose: any parent can raise the ballot, not only the School Fund owner
      // require(msg.sender == owner);

      Ballot storage newBallot;
      newBallot.ballotStart = block.timestamp;

      // remember all proposals
      for (uint i = 0; i < beneficiaries.length; i++)
      {
          newBallot.proposals[beneficiaries[i]] = Proposal({beneficiary: beneficiaries[i], description: descriptions[i], cost: costs[i], voteCount: 0});
          newBallot.beneficiaries.push(beneficiaries[i]);
      }      

      // replace old ballot
      ballot = newBallot;

      // notify all known parents about this new Ballot
      EventNewBallotAnnounced(beneficiaries, descriptions, costs);
   }


   // total individual contributions - sum of all money ever contributed. Only increases.
   mapping (address => uint) public balances;

   // total fund budget - sum of all money ever contributed. Only increases.
   uint totalFundBudget;

   // Every Parent can donate some funds an vote with the weight that is proportional to the total amount of money she ever contributed. 
   // It is possible to vote several times or even for various proposals within the same ballot. 
   function DonateAndVote(address beneficiary) public payable
   { 
      // verify that provided Proposal UID actually exists in the current ballot
      require(ballot.proposals[beneficiary].beneficiary == beneficiary);

      // remember total indivitual contribution
      balances[msg.sender] += msg.value;

      // update the total fund budget ever raised
      totalFundBudget += msg.value;

      // remember the last vote
      ballot.votes[msg.sender] = beneficiary;

      // remember the voter
      ballot.voters.push(msg.sender);
   }

   // at any moment we know the current winner
   function getWinningProposal() public constant returns (address winningProposal)
   {
      // calculate votes
      for (uint i = 0; i < ballot.voters.length; i++)
         ballot.proposals[ballot.votes[ballot.voters[i]]].voteCount += balances[ballot.voters[i]];
   
      // find the biggest one
      uint maxVotes = 0;
      for (uint j = 0; j < ballot.beneficiaries.length; j++)
         if (maxVotes < ballot.proposals[ballot.beneficiaries[j]].voteCount)
         {
            maxVotes = ballot.proposals[ballot.beneficiaries[j]].voteCount;
            winningProposal = ballot.beneficiaries[j];
         }
   }


}
 

