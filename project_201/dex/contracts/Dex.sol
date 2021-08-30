// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Dex is Wallet {
    using SafeMath for uint256;

    enum Side {
        BUY,
        SELL
    }

    struct Order {
        uint256 id;
        address trader;
        Side side;
        bytes32 ticker;
        uint256 amount;
        uint256 price;
        uint256 filled;
    }

    uint256 public nextOrderId = 0;

    mapping(bytes32 => mapping(uint256 => Order[])) orderBook;

    function getOrderBook(bytes32 ticker, Side side)
        public
        view
        returns (Order[] memory)
    {
        return orderBook[ticker][uint256(side)];
    }

    function createLimitOrder(
        Side side,
        bytes32 ticker,
        uint256 amount,
        uint256 price
    ) public {
        if (side == Side.BUY) {
            require(
                balances[msg.sender]["ETH"] >= amount.mul(price),
                "Seller has insufficient balance"
            );
        } else if (side == Side.SELL) {
            require(
                balances[msg.sender][ticker] >= amount.mul(price),
                "Seller has insufficient balance"
            );
        }

        Order[] storage orders = orderBook[ticker][uint256(side)];

        orders.push(
            Order(nextOrderId, msg.sender, side, ticker, amount, price)
        );

        // Bubble Sort:
        // The BUY order book should be ordered on price from highest to lowest starting at index 0
        uint256 i = orders.length > 0 ? orders.length - 1 : 0;

        if (side == Side.BUY) {
            for (i = orders.length - 1; i > 0; i--) {
                if (orders[i].price > orders[i - 1].price) {
                    Order memory orderToMove = orders[i];
                    orders[i] = orders[i - 1];
                    orders[i - 1] = orderToMove;
                }
            }
            // The SELL order book should be ordered on price from lowest to highest starting at index 0
        } else if (side == Side.SELL) {
            for (i = orders.length - 1; i > 0; i--) {
                if (orders[i].price < orders[i - 1].price) {
                    Order memory orderToMove = orders[i];
                    orders[i] = orders[i - 1];
                    orders[i - 1] = orderToMove;
                }
            }
        }

        nextOrderId++;
    }

    function createMarketOrder(
        Side side,
        bytes32 ticker,
        uint256 amount
    ) public {
        if (side == Side.SELL) {
          require(balances[msg.sender][ticker] >= amount, "Insufficient balance");
        }
        
        uint256 orderBookSide;
        orderBookSide = side == Side.BUY ? 1 : 0;
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint256 totalFilled = 0;

        // Loop through the order book:
        for (uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            uint leftToFill = amount.sub(totalFilled);
            uint availableToFill = orders[i].amount.sub(orders[i].filled);
            uint filled = 0;

            // How much we can fill from order[i]
            if (availableToFill > leftToFill) {
              filled = leftToFill; // Fill the entire market order
            } else {
              filled = availableToFill; // Fill as much as is available in limit order[i]
            }

            // update totalFilled
            totalFilled = totalFilled.add(filled);
            orders[i].filled = orders[i].filled.add(filled);
            uint cost = filled.mul(orders[i].price);
            
            // Execute the trader & shift balances between buyer/seller
            if (side == Side.BUY) {
              // Verify that the buyer has enough ETH to cover the purchase (require)
              require(balances[msg.sender]["ETH"] >= filled.mul(orders[i].price));
              // msg.sender is the buyer
              // Execute the trade -> transfer ETH from Buyer to Seller
              // and transfer tokens from Seller to Buyer
              balances[msg.sender][ticker] = balances[msg.sender][ticker].add(filled);
              balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].sub(cost);

              balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].sub(filled);
              balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].add(cost);
            } else if (side == Side.SELL) {
              // msg.sender is the seller
              // Execute the trade -> transfer ETH from Buyer to Seller
              // and transfer tokens from Seller to Buyer
              balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(filled);
              balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].add(cost);

              balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].add(filled);
              balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].sub(cost);
            }
        }

        // Remove 100% filled orders from the order book:
        while (orders[0].filled == orders[0].amount && orders.length > 0) {
          // Remove top element in the orders array by overwriting every element
          // with the next elemtn in the order list
          for (uint256 i = 0; i < orders.length - 1; i++) {
            orders[i] = orders[i + 1];
          }
          orders.pop();
        }
        
    }
}
