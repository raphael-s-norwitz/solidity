pragma solidity ^0.4.11;


contract AbstractENS {
    function setSubnodeOwner(bytes32 node, bytes32 hash, address owner);
    function setOwner(bytes32 node, address owner);
    function setResolver(bytes32 node, address resolver);
    function owner(bytes32 node) returns (address);
}


contract Deed {
    address public registrar;
    address constant BURN = 0xdead;
    uint public creationDate;
    address public owner;
    address public previousOwner;
    uint public value;
    event OwnerChanged(address newOwner);
    event DeedClosed();
    bool active;

    modifier onlyRegistrar {
        require(msg.sender == registrar);
        _;
    }

    modifier onlyActive {
        require(active);
        _;
    }

    function Deed(address _owner) payable {
        owner = _owner;
        registrar = msg.sender;
        creationDate = now;
        active = true;
        value = msg.value;
    }

    function setOwner(address newOwner) onlyRegistrar {
        require(newOwner != 0);
        previousOwner = owner;  // This allows contracts to check who sent them the ownership
        owner = newOwner;
        OwnerChanged(newOwner);
    }

    function setRegistrar(address newRegistrar) onlyRegistrar {
        registrar = newRegistrar;
    }

    function setBalance(uint newValue, bool throwOnFailure) onlyRegistrar onlyActive {
        // Check if it has enough balance to set the value
        require(value >= newValue);
        value = newValue;
        // Send the difference to the owner
        if (!owner.send(this.balance - newValue) && throwOnFailure) {
            revert();
        }
    }

    /**
     * @dev Close a deed and refund a specified fraction of the bid value
     *
     * @param refundRatio The amount*1/1000 to refund
     */
    function closeDeed(uint refundRatio) onlyRegistrar onlyActive {
        active = false;
        assert(BURN.send(((1000 - refundRatio) * this.balance)/1000));
        DeedClosed();
        destroyDeed();
    }

    /**
     * @dev Close a deed and refund a specified fraction of the bid value
     */
    function destroyDeed() {
        require(!active);

        // Instead of selfdestruct(owner), invoke owner fallback function to allow
        // owner to log an event if desired; but owner should also be aware that
        // its fallback function can also be invoked by setBalance
        if (owner.send(this.balance)) {
            selfdestruct(BURN);
        }
    }
}


// A mock ENS registrar that acts as FIFS but contains deeds
contract MockEnsRegistrar {
    AbstractENS public ens;
    bytes32 public rootNode;

    mapping (bytes32 => Entry) _entries;

    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    struct Entry {
        Deed deed;
        uint registrationDate;
        uint value;
        uint highestBid;
    }

    // Payable for easy funding
    function MockEnsRegistrar(AbstractENS _ens, bytes32 _rootNode) payable {
        ens = _ens;
        rootNode = _rootNode;
    }

    modifier onlyOwner(bytes32 hash) {
        require(msg.sender == _entries[hash].deed.owner());
        _;
    }

    modifier onlyUnregistered(bytes32 hash) {
        require(_entries[hash].deed == Deed(0));
        _;
    }

    function register(bytes32 hash) payable onlyUnregistered(hash) {
        _entries[hash].deed = (new Deed).value(msg.value)(msg.sender);
        _entries[hash].registrationDate = now;
        _entries[hash].value = msg.value;
        _entries[hash].highestBid = msg.value;
        ens.setSubnodeOwner(rootNode, hash, msg.sender);
    }

    function state(bytes32 hash) constant returns (Mode) {
        if (_entries[hash].registrationDate > 0) {
            return Mode.Owned;
        } else {
            return Mode.Open;
        }
    }

    function entries(bytes32 hash) constant returns (Mode, address, uint, uint, uint) {
        Entry storage h = _entries[hash];
        return (state(hash), h.deed, h.registrationDate, h.value, h.highestBid);
    }

    function deed(bytes32 hash) constant returns (address) {
        return _entries[hash].deed;
    }

    function transfer(bytes32 hash, address newOwner) onlyOwner(hash) {
        require(newOwner != 0);

        _entries[hash].deed.setOwner(newOwner);
        ens.setSubnodeOwner(rootNode, hash, newOwner);
    }

    // This allows anyone to invalidate any entry.  It's purely for testing
    // purposes and should never be seen in a live contract.
    function invalidate(bytes32 hash) {
        Entry storage h = _entries[hash];
        _tryEraseSingleNode(hash);
        _entries[hash].deed.closeDeed(0);
        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);
    }

    function _tryEraseSingleNode(bytes32 label) internal {
        if (ens.owner(rootNode) == address(this)) {
            ens.setSubnodeOwner(rootNode, label, address(this));
            var node = sha3(rootNode, label);
            ens.setResolver(node, 0);
            ens.setOwner(node, 0);
        }
    }
}
