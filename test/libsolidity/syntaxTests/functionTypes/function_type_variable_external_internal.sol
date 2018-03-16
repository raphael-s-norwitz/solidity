contract test {
    function fa(bytes memory) { }
    function(bytes memory) external internal a = fa;
}
// ----
// Warning: No visibility specified. Defaulting to "public".
// TypeError: Type function (bytes memory) is not implicitly convertible to expected type function (bytes memory) external.
