//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Staking_Bank {
    address public bankowner;

    struct User_Profile {
        uint256 Deposited_Amount;
        uint Locked_Time;
        bool Withdrawal;
    }

    mapping(address => User_Profile[]) addr_to_struct;
    mapping(address => uint256) addr_to_amount;
    
    constructor() {
        bankowner = msg.sender;
    }

    event Deposit_Event (address User, uint256 Amount);
    event Withdraw_Event (address User, uint256 Amount);

    function Deposit() public payable {
        addr_to_struct[msg.sender].push(User_Profile({
            Deposited_Amount: msg.value,
            Locked_Time: block.timestamp + 1 minutes,
            Withdrawal: false}));
        addr_to_amount[msg.sender] += msg.value;
        emit Deposit_Event(msg.sender, msg.value);
    }

    function Withdraw(uint256 Record_Index) public {
        User_Profile storage Deposit_Record = addr_to_struct[msg.sender][Record_Index];
        require(addr_to_amount[msg.sender] != 0, "User Does Not Exist");
        require(Deposit_Record.Locked_Time < block.timestamp, "You can't withdraw your amount yet");
        require(Deposit_Record.Withdrawal == false, "You have already withdrawn your amount");
        (bool Withdraw_Success,) = payable(msg.sender).call{value: (Deposit_Record.Deposited_Amount *11/10)}("");
        require(Withdraw_Success, "Withdraw Failed");
        addr_to_amount[msg.sender] -= Deposit_Record.Deposited_Amount;
        Deposit_Record.Withdrawal = true;
        emit Withdraw_Event(msg.sender, (Deposit_Record.Deposited_Amount *11/10));
    }

    function Early_Withdraw(uint256 Record_Index) public {
        User_Profile storage Deposit_Record = addr_to_struct[msg.sender][Record_Index];
        require(addr_to_amount[msg.sender] != 0, "User Does Not Exist");
        require(Deposit_Record.Withdrawal == false, "You have already withdrawn your amount");
        (bool Withdraw_Success,) = payable(msg.sender).call{value: (Deposit_Record.Deposited_Amount *99/100)}("");
        require(Withdraw_Success, "Withdraw Failed");
        addr_to_amount[msg.sender] -= Deposit_Record.Deposited_Amount;
        Deposit_Record.Withdrawal = true;
        emit Withdraw_Event(msg.sender, (Deposit_Record.Deposited_Amount *99/100));
        }

    function Check_UserBalance() public view returns (uint256) {
        require(addr_to_amount[msg.sender] != 0, "User Does Not Exist");
        return addr_to_amount[msg.sender];
    }

    function Check_BankBalance() public view returns (uint256) {
        require(msg.sender == bankowner, "No Permission");
        return address(this).balance;
    }
}