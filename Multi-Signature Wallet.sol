//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Multi_Signature_Wallet{
    
    address public Owner;
    uint256 public No_of_Users;
    uint256 public No_of_Signatures;
    uint256 public No_of_Signatures_Required = (No_of_Users/3)*2;

    constructor() {
        Owner = msg.sender;
    }

    modifier Only_Owner() {
        require(msg.sender == Owner, "No Persmission");
        _;
    }

    function Deposit() public payable {
        require(msg.value >0, "Nothing is sent");
        require(address_to_bool[msg.sender] == true, "No Permission");
        
    }

    function Withdraw(uint256 Withdraw_Amount) public{
        require(address_to_bool[msg.sender] == true, "No Permission");
        require(Withdraw_Amount <= address(this).balance, "Not Enough Balance");
        require(No_of_Signatures >= No_of_Signatures_Required, "Not Enough Signatures");
        (bool Withdraw_Success,) = msg.sender.call{value: Withdraw_Amount}("");
        require(Withdraw_Success, "Withdraw Failed");
        No_of_Signatures = 0;
    }
    
    function Check_Balance() public view returns (uint256) {
        require(address_to_bool[msg.sender] == true, "No Permission");
        return address(this).balance;
    }

    mapping(address => string) public address_to_name;
    mapping(string => address) public name_to_address;
    mapping(address => bool) public address_to_bool;

    function Add_User(string memory User_Name, address User_Address) public Only_Owner {
        require(name_to_address[User_Name] == address(0), "User Name Already Exists");
        require(address_to_bool[User_Address] == false, "User Address Already Exists");
        name_to_address[User_Name] = User_Address;
        address_to_name[User_Address] = User_Name;
        address_to_bool[User_Address] = true;
        No_of_Users++;
    }

    function Remove_User(string memory User_Name) public Only_Owner{
        address User_Removed = name_to_address[User_Name];
        address_to_bool[User_Removed] = false;
        delete name_to_address[User_Name];
        No_of_Users--;
    }

    function Sign() public {
        require(address_to_bool[msg.sender] == true, "No Permission");
        No_of_Signatures++;
    }
}
