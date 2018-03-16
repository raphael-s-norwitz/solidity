pragma experimental "v0.5.0";
contract C
{
    modifier only_owner() { _; }
    function foo() only_owner public;
    function bar() public only_owner;
}
// ----
// SyntaxError: Functions without implementation cannot have modifiers.
// SyntaxError: Functions without implementation cannot have modifiers.
