contract C {
    function f() public {
        delete f;
    }
}
// ----
// TypeError: Expression has to be an lvalue.
