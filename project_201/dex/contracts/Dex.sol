// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABITEncodeV2;

import "./Wallet.sol";

contract Dex is Wallet {

  enum Side {
    BUY,
    SELL
  }

  struct Order {
    uint id;
    address trader;
    Side side;
    bytes32 ticker;
    uint amount;
    uint price;
  }

  mapping(bytes32 => mapping(uint => Order[])) orderBook;

  function getOrderBook(bytes32 ticker, Side side) view public returns(Order[] memory) {
    return orderBook[ticker][uint(side)];
  }
}
