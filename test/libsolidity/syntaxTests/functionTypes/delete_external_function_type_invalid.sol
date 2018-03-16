contract C {
    function f() public {
        delete this.f;
    }
}
// ----
// TypeError: Expression has to be an lvalue.
