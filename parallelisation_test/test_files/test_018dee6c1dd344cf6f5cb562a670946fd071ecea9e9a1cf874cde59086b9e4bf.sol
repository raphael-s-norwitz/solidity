pragma solidity ^0.4.11;
import "../core/common/Object.sol";
import '../core/event/MultiEventsHistoryAdapter.sol';

contract Lockup6mEmitter is MultiEventsHistoryAdapter {
        event Error(bytes32 message);

        function emitError(bytes32 _message) {
           Error(_message);
        }
}

contract Lockup6m is Object, Lockup6mEmitter {

    uint constant TIME_LOCK_SCOPE = 51000;
    uint constant TIME_LOCK_TRANSFER_ERROR = TIME_LOCK_SCOPE + 10;
    uint constant TIME_LOCK_TRANSFERFROM_ERROR = TIME_LOCK_SCOPE + 11;
    uint constant TIME_LOCK_BALANCE_ERROR = TIME_LOCK_SCOPE + 12;
    uint constant TIME_LOCK_TIMESTAMP_ERROR = TIME_LOCK_SCOPE + 13;
    uint constant TIME_LOCK_INVALID_INVOCATION = TIME_LOCK_SCOPE + 17;
    

    // custom data structure to hold locked funds and time
    struct accountData {
        uint balance;
        uint releaseTime;
    }

    // Should use interface of the emitter, but address of events history.
    address public eventsHistory;

    address asset;

    accountData lock;

    function Lockup6m(address _asset) {
        asset = _asset;
    }

    /**
     * Emits Error event with specified error message.
     *
     * Should only be used if no state changes happened.
     *
     * @param _errorCode code of an error
     * @param _message error message.
     */
    function _error(uint _errorCode, bytes32 _message) internal returns(uint) {
        Lockup6mEmitter(eventsHistory).emitError(_message);
        return _errorCode;
    }

    /**
     * Sets EventsHstory contract address.
     *
     * Can be set only once, and only by contract owner.
     *
     * @param _eventsHistory MultiEventsHistory contract address.
     *
     * @return success.
     */
    function setupEventsHistory(address _eventsHistory) returns(uint errorCode) {
        errorCode = checkOnlyContractOwner();
        if (errorCode != OK) {
            return errorCode;
        }
        if (eventsHistory != 0x0 && eventsHistory != _eventsHistory) {
            return TIME_LOCK_INVALID_INVOCATION;
        }
        eventsHistory = _eventsHistory;
        return OK;
    }

    function payIn() returns(uint errorCode) {
        // send some amount (in Wei) when calling this function.
        // the amount will then be placed in a locked account
        // the funds will be released once the indicated lock time in seconds
        // passed and can only be retrieved by the same account which was
        // depositing them - highlighting the intrinsic security model
        // offered by a blockchain system like Ethereum
        errorCode = checkOnlyContractOwner();
        if (errorCode != OK) {
            return errorCode;
        }
        uint amount = ERC20Interface(asset).balanceOf(this);
        if(lock.balance != 0) {
            if(lock.balance != amount) {
                lock.balance == amount;
                return OK;
            }
            return _error(TIME_LOCK_INVALID_INVOCATION,'INVALID INVOCATION');
        }
        if (amount == 0) {
            return _error(TIME_LOCK_BALANCE_ERROR,'BALANCE ERROR');
        }
        lock = accountData(amount,now + 180 days);
        return OK;
    }
    
    function payOut(address _getter) returns(uint errorCode) {
        errorCode = checkOnlyContractOwner();
        if (errorCode != OK) {
            return errorCode;
        }
        // check if user has funds due for pay out because lock time is over
        uint amount = lock.balance;
        if (now < lock.releaseTime) {
            return _error(TIME_LOCK_TIMESTAMP_ERROR,'TIMESTAMP ERROR');
        }
        if (amount == 0) {
            return _error(TIME_LOCK_BALANCE_ERROR,'BALANCE ERROR');
        }
        if(!ERC20Interface(asset).transfer(_getter,amount)) {
            return _error(TIME_LOCK_TRANSFER_ERROR,'TRANSFER ERROR');
        } 
        selfdestruct(msg.sender);     
        return OK;
    }

    function getLockedFunds() constant returns (uint) {
        return lock.balance;
    }
    
    function getLockedFundsReleaseTime() constant returns (uint) {
	    return lock.releaseTime;
    }

}
