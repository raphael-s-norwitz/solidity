contract C {
    // This is an error, you should explicitly use
    // `external public` to fix it - `internal public` does not exist.
    function(bytes memory) public a;
}
// ----
// TypeError: Invalid visibility, can only be "external" or "internal".
