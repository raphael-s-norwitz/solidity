// It should not be possible to return internal functions from external functions.
contract C {
    function f() public returns (function(uint) internal returns (uint) x) {
    }
}
// ----
// TypeError: Internal or recursive type is not allowed for public or external functions.
