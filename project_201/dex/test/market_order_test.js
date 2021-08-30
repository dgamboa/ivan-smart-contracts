const Dex = artifacts.require("Dex");
const Link = artifacts.require("Link");
const truffleAssert = require("truffle-assertions");

contract("Dex", (accounts) => {
  // When creating a SELL market order, the seller needs to have enough tokens for the trade
  it("should make sure seller has enough tokens to create a SELL market order", async () => {
    let dex = await Dex.deployed();

    let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"));
    assert.equal(balance.toNumber(), 0, "Initial LINK balance is not 0");

    await truffleAssert.reverts(
      dex.createMarketOrder(1, web3.utils.fromUtf8("LINK"), 10)
    );
  });

  // Market orders can be submitted even if the order book is empty
  it("should submit market order even if the order book is empty", async () => {
    let dex = await Dex.deployed();

    await dex.depositEth({ value: 100000 });

    let orderBook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
    assert(orderBook.length == 0, "Buy side order book length is not 0");

    await truffleAssert.passes(
      dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10)
    );
  });

  // Market orders should be filled until the order book is empty or the market order is 100% filled
  it("should fill limit orders up to the amount of the market orders", async () => {
    let dex = await Dex.deployed();
    let link = await Link.deployed();

    let orderBook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1);
    assert(
      orderBook.length == 0,
      "Sell side order book should be empty at start"
    );

    await dex.addToken(web3.utils.fromUtf8("LINK"), link.address);

    // Send LINK tokens to accounts 1, 2, 3 from account 0
    await link.transfer(accounts[1], 150);
    await link.transfer(accounts[2], 150);
    await link.transfer(accounts[3], 150);

    // Approve DEX for accounts 1, 2, 3
    await link.approve(dex.address, 50, { from: accounts[1] });
    await link.approve(dex.address, 50, { from: accounts[2] });
    await link.approve(dex.address, 50, { from: accounts[3] });

    // Deposit LINK into DEX for accounts 1, 2, 3
    await dex.deposit(50, web3.utils.fromUtf8("LINK"), { from: accounts[1] });
    await dex.deposit(50, web3.utils.fromUtf8("LINK"), { from: accounts[2] });
    await dex.deposit(50, web3.utils.fromUtf8("LINK"), { from: accounts[3] });

    // Fill up the sell order book
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 300, {
      from: accounts[1],
    });
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 400, {
      from: accounts[2],
    });
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 500, {
      from: accounts[3],
    });

    // Create market order that should fill 2/3 orders in the book
    await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 10);

    orderBook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1);
    assert(
      orderBook.length == 1,
      "Sell side order book should only have 1 order left"
    );
    assert((orderBook[0].filled == 0), "Sell side order should have 0 filled");
  });

  // Market orders should be filled until the order book is empty or the market order is 100% filled
  it("should fill market orders until the book is empty", async () => {
    let dex = await Dex.deployed();

    let orderBook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1);
    assert(
      orderBook.length == 1,
      "Sell side order book should have 1 order left"
    );

    // Fill up the sell order book again
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 400, {
      from: accounts[1],
    });
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 500, {
      from: accounts[2],
    });

    // Check buyer link balance before link purchase
    let balanceBefore = await dex.balances(
      accounts[0],
      web3.utils.fromUtf8("LINK")
    );

    // Create a market order that could fill more than the entire order book (15 link)
    await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 50);

    // Check buyer link balance after link purchase
    let balanceAfter = await dex.balances(
      accounts[0],
      web3.utils.fromUtf8("LINK")
    );

    // Buyer should have 15 more LINK after, even though the order was for 50
    assert.equal(balanceBefore.toNumber() + 15, balanceAfter.toNumber());
  });

  // The ETH balance of the buyer should decrease with the filled amount
  it("should decrease ETH balance for buyer with the filled order amount", async () => {
    let dex = await Dex.deployed();
    let link = await Link.deployed();

    // Seller deposits link and creates a sell limit order for 1 LINK for 300 wei
    await link.approve(dex.address, 500, { from: accounts[1] });
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300, {
      from: accounts[1],
    });

    // Check buyer ETH balance before trade
    let balanceBefore = await dex.balances(
      accounts[0],
      web3.utils.fromUtf8("ETH")
    );
    await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 1);
    let balanceAfter = await dex.balances(
      accounts[0],
      web3.utils.fromUtf8("ETH")
    );

    assert.equal(balanceBefore - 300, balanceAfter);
  });

  // The token balances of the limit order sellers should decrease with the filled amounts
  it("should decrease token balance of limit order seller with filled amounts", async () => {
    let dex = await Dex.deployed();
    let link = await Link.deployed();

    let orderBook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1);
    assert(
      orderBook.length == 0,
      "Sell side order book should be empty at start"
    );

    // Seller account[1] already has approved and deposited LINK

    // Seller account[2] deposits LINK
    await link.approve(dex.address, 500, { from: accounts[2] });
    await dex.deposit(100, web3.utils.fromUtf8("LINK"), { from: accounts[2] });

    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300, {
      from: accounts[1],
    });
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 400, {
      from: accounts[2],
    });

    // Check sellers LINK balances before trade
    let account1BalanceBefore = await dex.balances(
      accounts[1],
      web3.utils.fromUtf8("LINK")
    );
    let account2BalanceBefore = await dex.balances(
      accounts[2],
      web3.utils.fromUtf8("LINK")
    );

    // Account[0] created market order to buy up both sell orders
    await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 2);

    // Check sellers LINK balances after trade
    let account1BalanceAfter = await dex.balances(
      accounts[1],
      web3.utils.fromUtf8("LINK")
    );
    let account2BalanceAfter = await dex.balances(
      accounts[2],
      web3.utils.fromUtf8("LINK")
    );

    assert.equal(
      account1BalanceBefore.toNumber() - 1,
      account1BalanceAfter.toNumber()
    );
    assert.equal(
      account2BalanceBefore.toNumber() - 1,
      account2BalanceAfter.toNumber()
    );
  });

  // ***Filled limit orders should be removed from the order book
  it("Filled limit orders should be removed from the orderbook", async () => {
    let dex = await Dex.deployed();
    let link = await Link.deployed();
    await dex.addToken(web3.utils.fromUtf8("LINK"), link.address);

    //Seller deposits link and creates a sell limit order for 1 link for 300 wei
    await link.approve(dex.address, 500);
    await dex.deposit(50, web3.utils.fromUtf8("LINK"));

    await dex.depositEth({ value: 10000 });

    let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1); //Get sell side orderbook

    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300);
    await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 1);

    orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1); //Get sell side orderbook
    assert(
      orderbook.length == 0,
      "Sell side Orderbook should be empty after trade"
    );
  });

  //Partly filled limit orders should be modified to represent the filled/remaining amount
  it("Limit orders filled property should be set correctly after a trade", async () => {
    let dex = await Dex.deployed();

    let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1); //Get sell side orderbook
    assert(
      orderbook.length == 0,
      "Sell side Orderbook should be empty at start of test"
    );

    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 300, {
      from: accounts[1],
    });
    await dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 2);

    orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1); //Get sell side orderbook
    assert.equal(orderbook[0].filled, 2);
    assert.equal(orderbook[0].amount, 5);
  });

  //When creating a BUY market order, the buyer needs to have enough ETH for the trade
  it("Should throw an error when creating a buy market order without adequate ETH balance", async () => {
    let dex = await Dex.deployed();

    let balance = await dex.balances(accounts[4], web3.utils.fromUtf8("ETH"));
    assert.equal(balance.toNumber(), 0, "Initial ETH balance is not 0");
    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 300, {
      from: accounts[1],
    });

    await truffleAssert.reverts(
      dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 5, {
        from: accounts[4],
      })
    );
  });

  // When creating a BUY market order, the buyer needs to have enough ETH for the trade
  it("should throw an error when creating a buy market order without enough ETH balance", async () => {
    let dex = await Dex.deployed();

    let balance = await dex.balances(accounts[4], web3.utils.fromUtf8("ETH"));
    assert.equal(balance.toNumber(), 0, "Initial ETH balance is not 0");

    await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 5, 300, {
      from: accounts[0],
    });

    await truffleAssert.reverts(
      dex.createMarketOrder(0, web3.utils.fromUtf8("LINK"), 5, {
        from: accounts[4],
      })
    );
  });
});
