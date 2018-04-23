pragma solidity ^0.4.4;

import "Managed.sol";
import "ChronoMintConfigurable.sol";
import "Stub.sol";
import "LOC.sol";
import "LaborHourToken.sol";

contract ChronoMint is Managed, Configurable {
  uint private offeringCompaniesByIndex;
  LaborHourToken[] LaborHourTokensByIndex;
  mapping(uint => address) public offeringCompanies;
  mapping(address => LaborHourToken) public laborHourTokens;
  event newLOC(address _from, address _LOC);

  function getAddress(string name) constant returns(address) {
    return address(settings[name]);
  }

  function isCBE(address key) returns(bool) {
      if (authorizedKeys[key]){
        return true;
      }
      else
        return false;
  }
  function getValue(string name) constant returns(uint) {
    return settings[name];
  }

  function setAddress(string name, address value) onlyAuthorized {
    setValue(name,uint(value));
  }

  function setValue(string name, uint value) byVote(address(this), name, settings[name], value, true) onlyAuthorized() {
    setVal(name,uint(value));
  }

  function setContractValue(address subject, string name, uint value) byVote(subject, name, ChronoMintConfigurable(subject).getVal(name), value, true) onlyAuthorized() {
    ChronoMintConfigurable(subject).setValue(name,uint(value));
  }

  function proposeLOC (string _name, address _controller, uint _issueLimit, string _publishedHash, uint _expDate) onlyAuthorized returns(address) {
    address locAddr = new LOC();
    offeringCompanies[offeringCompaniesByIndex] = locAddr;
    LOC loc = LOC(locAddr);
    loc.setLOCdata(_name,msg.sender,_controller,_issueLimit,_publishedHash,_expDate);
    approveContract(locAddr);
    newLOC(msg.sender, locAddr);
    offeringCompaniesByIndex++;
    return locAddr;
  }

  function getLOCbyID(uint _id) returns(address) {
    return offeringCompanies[_id];
  }

  function getLOCCount () returns(uint) {
      return offeringCompaniesByIndex;
  }

  function proposeLaborHourToken (address newlaborHourToken) onlyAuthorized {
    laborHourTokens[newlaborHourToken] = LaborHourToken(newlaborHourToken);
    approveContract(newlaborHourToken);
  }

  function addLOCtoLHT(address laborOfferingContract, address laborHourToken) byVote(laborHourToken, 'associate', 0x0, uint(laborOfferingContract), false) {
    LaborHourToken(laborHourToken).addLOC(laborOfferingContract);
  }

  function approveContract(address newContract) onlyAuthorized() byVote(address(this), 'deployable', 0x0, uint(newContract), false) {
    ChronoMintConfigurable(newContract).approved();
  }

  function ChronoMint(address _tc, address _rc, address _ec){
    settings['timeContract'] = uint(_tc);
    settings['rewardsContract'] = uint(_rc);
    settings['exchangeContract'] = uint(_ec);
    settings['securityPercentage'] = 1;
    settings['liquidityPercentage'] = 1;
    settings['insurancePercentage'] = 1;
    settings['insuranceDuration'] = 1;
  }

  function()
  {
    throw;
  }
}


contract TimeContract is Stub {}

contract RewardsContract is Stub {}
