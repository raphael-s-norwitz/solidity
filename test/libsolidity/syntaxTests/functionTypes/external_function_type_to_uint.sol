contract C {
    function f() public returns (uint) {
        return uint(this.f);
    }
}
// ----
// TypeError: Explicit type conversion not allowed from "function () external returns (uint256)" to "uint256".
