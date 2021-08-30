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
        uint256 orderBookSide;
        orderBookSide = side == Side.BUY ? 1 : 0;
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint256 totalFilled;

        for (uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            // How much we can fill from order[i]
            // update totalFilled
            // Execute the trader & shift balances between buyer/seller
            // Verify that the buyer has enough ETH to cover purchase (require)
        }

        // Loop through the order book and remove 100% filled orders
        
    }
}
