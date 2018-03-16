contract C {
    function() external returns (function () internal) x;
}
// ----
// TypeError: Internal type cannot be used for external function type.
