contract C {
    function (uint) internal payable returns (uint) x;

    function g() public {
        x = g;
    }
}
// ----
// TypeError: Only external function types can be payable.
