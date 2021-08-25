## Assignment OpenZeppelin
*Reference: https://medium.com/upstate-interactive/solidity-override-vs-virtual-functions-c0a5dfb83aaf*

1. When should you put the virtual keyword on a function?
Whenever the function can or should be overridden by a contract that inherits the function.

2. When should you put the keyword override on a function?
Whenever a function overrides an inherited function.

3. Why would a function have both virtual and override keywords on it?
When a function overrides an inherited function but can also be overridden by children contracts, it should include both the `virtual` and `override` keywords.
