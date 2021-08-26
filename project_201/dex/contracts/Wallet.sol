// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Wallet {

  struct Token {
    bytes32 ticker;
    address tokenAddress;
  }
  mapping(bytes32 => Token) public tokenMapping;
  bytes32[] public tokenList;

  mapping(address => mapping(bytes32 => uint256)) public balances;

}
