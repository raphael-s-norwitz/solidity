pragma solidity 0.4.15;

// Inspired by https://github.com/reverendus/tx-manager

contract EVMCallScriptRunner {
    function runScript(bytes script) internal {
        uint256 location = 0;
        while (location < script.length) {
            address contractAddress = addressAt(script, location);
            uint256 calldataLength = uint256(uint32At(script, location + 0x14));
            uint256 calldataStart = locationOf(script, location + 0x14 + 0x04);
            uint8 ok;
            assembly {
                ok := call(sub(gas, 5000), contractAddress, 0, calldataStart, calldataLength, 0, 0)
            }
            if (ok == 0) revert();

            location += (0x14 + 0x04 + calldataLength);
        }
    }

    function uint256At(bytes data, uint256 location) internal returns (uint256 result) {
        assembly {
            result := mload(add(data, add(0x20, location)))
        }
    }

    function addressAt(bytes data, uint256 location) internal returns (address result) {
        uint256 word = uint256At(data, location);

        assembly {
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000),
                          0x1000000000000000000000000)
        }
    }

    function uint32At(bytes data, uint256 location) internal returns (uint32 result) {
        uint256 word = uint256At(data, location);

        assembly {
            result := div(and(word, 0xffffffff00000000000000000000000000000000000000000000000000000000),
                                   0x100000000000000000000000000000000000000000000000000000000)
        }
    }

    function locationOf(bytes data, uint256 location) internal returns (uint256 result) {
        assembly {
            result := add(data, add(0x20, location))
        }
    }
}

contract EVMCallScriptDecoder is EVMCallScriptRunner {
    function getScriptActionsCount(bytes script) internal constant returns (uint256 i) {
        uint256 location = 0;
        while (location < script.length) {
            location += (0x14 + 0x04 + uint256(uint32At(script, location + 0x14)));
            i++;
        }
    }

    function getScriptAction(bytes script, uint256 i) internal constant returns (address, bytes) {
        uint256 location = 0;
        while (location < script.length) {
            if (i == 0) {
                uint256 length = uint256(uint32At(script, location + 0x14));
                address addr = addressAt(script, location);
                bytes memory calldata = new bytes(length);
                uint calldataPtr;
                assembly { calldataPtr := add(calldata, 0x20) }
                memcpy(calldataPtr, locationOf(script, location + 0x14 + 0x04), length);
                return (addr, calldata);
            }

            location += (0x14 + 0x04 + uint256(uint32At(script, location + 0x14)));
            i--;
        }
    }

    // From https://github.com/Arachnid/solidity-stringutils
   function memcpy(uint dest, uint src, uint len) private {
       // Copy word-length chunks while possible
       for(; len >= 32; len -= 32) {
           assembly {
               mstore(dest, mload(src))
           }
           dest += 32;
           src += 32;
       }

       // Copy remaining bytes
       uint mask = 256 ** (32 - len) - 1;
       assembly {
           let srcpart := and(mload(src), not(mask))
           let destpart := and(mload(dest), mask)
           mstore(dest, or(destpart, srcpart))
       }
   }
}
