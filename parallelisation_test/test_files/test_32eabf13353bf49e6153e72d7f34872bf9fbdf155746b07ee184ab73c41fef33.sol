pragma solidity ^0.4.11;
contract AnotherStorage {
  address public simpleStorageAddress;
  address simpleStorageAddress2;

  function AnotherStorage(address addr) {
    simpleStorageAddress = addr;
  }

}
