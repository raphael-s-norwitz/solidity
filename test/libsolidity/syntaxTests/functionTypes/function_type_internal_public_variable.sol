contract C {
    function(bytes memory) internal public a;
}
// ----
// TypeError: Internal or recursive type is not allowed for public state variables.
