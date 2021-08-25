// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract MyToken is ERC20Capped {
  constructor() ERC20("MyToken", "MTKN") ERC20Capped(100000) {}

  function mint (uint256 amount) public virtual {
    _mint(msg.sender, amount);
  }
}
