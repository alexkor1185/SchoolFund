// Author: Alex
// Date: 2017-Oct-15, Ukraine

pragma solidity ^0.4.17;

# https://github.com/ethereum/go-ethereum/wiki/Contract-Tutorial

/**
 * Mortal ancestor provides a valid way for the contract owner to destroy it to free Ethereum blockchain.
**/
contract Mortal
{
   address public owner;

   function mortal()
   {
      owner = msg.sender;
   }

   function kill()
   {
      if (msg.sender == owner)
         suicide(owner);
   }
}

// https://solidity.readthedocs.io/en/develop/introduction-to-smart-contracts.html
// https://solidity.readthedocs.io/en/develop/solidity-by-example.html

/// @title School Charity Fund
contract SchoolCharityFund is Mortal
{
   // Parent can invest and vote for the way how the money shall be spent
   struct Parent
   {
      address parent;
      uint donated; // for info only
      uint weight; vote weight = donated / totalFundBudget;
      uint vote;  
   }

   // Proposal on how to spend the money
   struct Proposal
   {
      uint32 uid; // globally unique ID of the proposal
      bytes256 description;
      uint voteCount;
   }

   // remember the history of every ballot
   mapping(Proposal => mapping(address => Voter)) public ballots;

   // remember voters: we cannot calculate weights until all voters stop voting for the given proposal
   mapping(uint32 => address[]) private proposalsToParents;

   // remember who voted for what
   mapping(address => uint32[]) private parentsToProposals;

   // here is the list of all expenditure proposals
   Proposal[] public proposals;

   // raise another ballot and notify the parents
   function InitNewBallot(bytes32[] proposalNames, mapping(bytes32 => bytes32) descriptions)
   {
      // any parent can raise the ballot, not only the Charity Fund owner
      // require(msg.sender == owner);

      // remember all proposals
      for (uint i = 0; i < proposalNames.length; i++)
          proposals.push(Proposal({name: proposalNames[i], description: descriptions[proposalNames[i]], voteCount: 0}));
      
      // notify all known parents about this new Ballot
      // <to be added>
   }

   // Total fund budget - sum of all money ever contributed. Only increases.
   uint totalFundBudget;

   // Every Parent can donate some funds an vote with the weight 
   // that is proportional to the total amount of money she ever contributed. 
   function DonateAndVote(uint32 proposalUID, uint amount)
   { 
      // it is possible to vote several times only for the same Proposal
      require((parentsToProposals[msg.sender][proposalUID] == 0) || (parentsToProposals[msg.sender][proposalUID] == ));

      // remember the contribution
      balances[msg.sender] += amount;

      // update the total fund budget ever raised
      totalFundBudget += amount;

      // remember 
   }





   /**
    * How much every individual participating parent has contributed.
   **/
   mapping (address => uint) public balances;

   /**
    * Total current budget of the fund.
   **/
   uint fundBudget;

   /**
    * Notification about another charity or expenditure.
   **/
   event Sent(address from, address to, uint amount, bytes256 message);
   
   


   /**
    * Donate - let anybody to give money for the charity fund.
   **/
   function Donate(uint amount)
   {
      // remember everyone's contribution
      balances[msg.sender] += amount;

      // add the money to the charity budget
      balances[owner] += amount;
   }

   /**
    * Spend - use some money for an activity.
   **/
   function Spend(address to, uint amount, bytes256 message)
   {
      // charity fund has to have enough money to transfer
      require(balances[owner] >= amount); 

      // withdraw funds from charity account        
      balances[owner] -= amount;

      // send money somewhere here
      // <to be updated>
      
      // notify
      Sent(owner, to, amount, message)
   }

   /**
    * Spending funds goes through an auction.
    * See https://solidity.readthedocs.io/en/develop/solidity-by-example.html
   **/
   function SpendAuction(uint biddingTime, address beneficiary)
   {
      
   }





}
 

