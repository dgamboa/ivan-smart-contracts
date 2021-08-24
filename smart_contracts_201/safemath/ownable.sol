pragma solidity 0.8.0;

contract Ownable {
    
    address internal owner;
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only admins can add balances");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }    
}
