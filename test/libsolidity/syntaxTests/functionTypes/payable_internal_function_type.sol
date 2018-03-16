contract C {
    function (uint) internal payable returns (uint) x;
}
// ----
// TypeError: Only external function types can be payable.
