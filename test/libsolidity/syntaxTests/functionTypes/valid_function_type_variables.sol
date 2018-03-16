contract test {
    function fa(uint) {}
    function fb(uint) internal {}
    function fc(uint) internal {}
    function fd(uint) external {}
    function fe(uint) external {}
    function ff(uint) internal {}
    function fg(uint) internal pure {}
    function fh(uint) pure internal {}

    function(uint) a = fa;
    function(uint) internal b = fb; // (explicit internal applies to the function type)
    function(uint) internal internal c = fc;
    function(uint) external d = this.fd;
    function(uint) external internal e = this.fe;
    function(uint) internal public f = ff;
    function(uint) internal pure public g = fg;
    function(uint) pure internal public h = fh;
}
// ----
// Warning: No visibility specified. Defaulting to "public".
// TypeError: Internal or recursive type is not allowed for public state variables.
// TypeError: Internal or recursive type is not allowed for public state variables.
// TypeError: Internal or recursive type is not allowed for public state variables.
