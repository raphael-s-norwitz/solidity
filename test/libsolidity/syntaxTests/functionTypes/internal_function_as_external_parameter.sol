// It should not be possible to give internal functions
// as parameters to external functions.
contract C {
    function f(function(uint) internal returns (uint) x) public {
    }
}
// ----
// TypeError: Internal or recursive type is not allowed for public or external functions.
