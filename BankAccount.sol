pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;
//BankAccount V1
/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) pure internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) pure internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) pure internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) pure internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a < b ? a : b;
  }
}

contract BankAccount {
    
    using SafeMath for uint256;
    // BankAccount
    uint public year = 2018; // initial bank establish year 
    uint public interestRate = 5; // 5 percent
     
    struct Account {
        string name;
        uint accountNumber; //compose of integer + 2 decimal place xx.xx
        uint balance;
    }
    
    // Account
    Account[] public accounts;
    
    //1. create account
    function createAccount(string name) public returns (uint) {
        Account memory acc = Account(name, getTotalAccount(), 0);
        return accounts.push(acc).add(1); // accountNumber (index number)
    }
    
    //2. deposit money
    function deposit(uint accountNumber) public payable 
    accountContains(accountNumber) returns (uint) {
        require(msg.value > 0);
        
        accounts[accountNumber].balance = (accounts[accountNumber].balance).add(msg.value / 10 ** 18);
        return accounts[accountNumber].balance;
    }
    
    //3. withdraw money
    function withdraw(uint accountNumber, uint withdrawAmount) public 
    accountContains(accountNumber) returns (uint) {
        Account storage account = accounts[accountNumber];
        require(account.balance >= withdrawAmount);
        
        account.balance = (account.balance).sub(withdrawAmount);
        msg.sender.transfer(withdrawAmount);
        return account.balance;
    }
    
    //4. check balance
    function checkBalance(uint accountNumber) accountContains(accountNumber) public view returns (uint) {
        return accounts[accountNumber].balance;
    }
    
    event accountDetail(string name, uint accountNumber, uint balance);
    
    //5. display account detail
    function displayAccountDetail(uint accountNumber) accountContains(accountNumber) public view returns (string, uint, uint) {
        Account memory acc = accounts[accountNumber];
        emit accountDetail(acc.name, acc.accountNumber, acc.balance);
        return (acc.name, acc.accountNumber, acc.balance);
    }
    
    //6. increase year
    function increaseYear() public returns (uint) { //returns currentYear
        year++; // increase 1 year from now 
        for(uint i=0;i < getTotalAccount(); i++) {
            accounts[i].balance = updateBalance(accounts[i].balance);
        }
        
        return year;
    }
    
    // helper functions
    function updateBalance(uint currentBalance) private view returns (uint) {
        return currentBalance.add(calculateInterest(currentBalance));
    }
    
    function calculateInterest(uint currentBalance) private view returns (uint) {
        return currentBalance.mul(interestRate).div(100);
    }
    
    function getTotalAccount() public view returns (uint) {
        return accounts.length;
    }
    
    function accountIsEmpty() private view returns (bool) {
        return getTotalAccount() == 0;
    }
    
    modifier accountContains(uint accountNumber) {
        require(0 <= accountNumber && accountNumber < getTotalAccount());
        _;
    }
    
}