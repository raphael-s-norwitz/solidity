pragma solidity ^0.4.6;


import "./Court.sol";

contract BuyableCourt is Court {
    function BuyableCourt(address[] accounts, uint256[] tokens) Court(accounts,tokens) {}

    function buyTokens() payable {
        balances[msg.sender]+=msg.value;
    }
}
