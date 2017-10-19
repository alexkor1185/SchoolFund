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
   event EventNewBallotAnnounced(bytes32[] proposalUIDs, bytes32[] descriptions, uint[] costs);

   // Proposal on how to spend the money
   struct Proposal
   {
      bytes32 uid; // globally unique ID of the proposal
      bytes32 description;
      uint cost;
      uint voteCount;
   }

   struct Ballot
   {
      // here is the list of all expenditure proposals
      mapping(bytes32 => Proposal) proposals;
      
      // remember proposal UIDs (there is no way to get mapping keys otherwise)
      bytes32[] UIDs;

      // remember the votes
      mapping(address => bytes32) votes;

      // remember voters (there is no way to get mapping keys otherwise)
      address[] voters;
   }

   Ballot private ballot;

   // raise another ballot and notify the parents
   function InitNewBallot(bytes32[] proposalUIDs, bytes32[] descriptions, uint[] costs) public
   {
      // this is commented on purpose: any parent can raise the ballot, not only the School Fund owner
      // require(msg.sender == owner);

      Ballot storage newBallot;

      // remember all proposals
      for (uint i = 0; i < proposalUIDs.length; i++)
      {
          newBallot.proposals[proposalUIDs[i]] = Proposal({uid: proposalUIDs[i], description: descriptions[i], cost: costs[i], voteCount: 0});
          newBallot.UIDs.push(proposalUIDs[i]);
      }      

      // replace old ballot
      ballot = newBallot;

      // notify all known parents about this new Ballot
      EventNewBallotAnnounced(proposalUIDs, descriptions, costs);
   }


   // total individual contributions - sum of all money ever contributed. Only increases.
   mapping (address => uint) public balances;

   // total fund budget - sum of all money ever contributed. Only increases.
   uint totalFundBudget;

   // Every Parent can donate some funds an vote with the weight that is proportional to the total amount of money she ever contributed. 
   // It is possible to vote several times or even for various proposals within the same ballot. 
   function DonateAndVote(bytes32 proposalUID, uint amount) public
   { 
      // verify that provided Proposal UID actually exists in the current ballot
      require(ballot.proposals[proposalUID].uid == proposalUID);

      // remember total indivitual contribution
      balances[msg.sender] += amount;

      // update the total fund budget ever raised
      totalFundBudget += amount;

      // remember the last vote
      ballot.votes[msg.sender] = proposalUID;

      // remember the voter
      ballot.voters.push(msg.sender);
   }

   // at any moment we know the current winner
   function getWinningProposal() public constant returns (bytes32 winningProposalUID)
   {
      // calculate votes
      for (uint i = 0; i < ballot.voters.length; i++)
         ballot.proposals[ballot.votes[ballot.voters[i]]].voteCount += balances[ballot.voters[i]];
   
      // find the biggest one
      uint maxVotes = 0;
      for (uint j = 0; j < ballot.UIDs.length; j++)
         if (maxVotes < ballot.proposals[ballot.UIDs[j]].voteCount)
         {
            maxVotes = ballot.proposals[ballot.UIDs[j]].voteCount;
            winningProposalUID = ballot.UIDs[j];
         }
   }


}
 

