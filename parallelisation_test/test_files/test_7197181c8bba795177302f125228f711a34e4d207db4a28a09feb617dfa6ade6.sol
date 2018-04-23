pragma solidity ^0.4.21;

import "contracts/Interface/SchedulerInterface.sol";

/// Example of using the Scheduler from a smart contract to delay a payment.
contract DelayedPayment {

    SchedulerInterface public scheduler;

    uint lockedUntil;
    address recipient;

    function DelayedPayment(
        address _scheduler,
        uint    _numBlocks,
        address _recipient
    )  public {
        scheduler = SchedulerInterface(_scheduler);
        lockedUntil = block.number + _numBlocks;
        recipient = _recipient;

        scheduler.schedule.value(2 ether)(
            recipient,              // toAddress
            "",                     // callData
            [
                2000000,            // The amount of gas to be sent with the transaction.
                0,                  // The amount of wei to be sent.
                255,                // The size of the execution window.
                lockedUntil,        // The start of the execution window.
                30000000000 wei,    // The gasprice for the transaction (aka 30 gwei)
                12345 wei,          // The fee included in the transaction.
                224455 wei,         // The bounty that awards the executor of the transaction.
                20000 wei           // The required amount of wei the claimer must send as deposit.
            ]
        );
    }

    function ()  public {
        if (address(this).balance > 0) {
            payout();
        } else {
            revert();
        }
    }

    function payout()
        public returns (bool)
    {
        require(getNow() >= lockedUntil);
        recipient.transfer(address(this).balance);
        return true;
    }

    function getNow()
        internal view returns (uint)
    {
        return block.number;
    }
}