pragma solidity ^0.4.3;


contract Owner {
  modifier onlyowner() {
    // only allow a message sender than is the owner
    if (msg.sender == owner) {
      _;
    }
  }

  address public owner;
}
