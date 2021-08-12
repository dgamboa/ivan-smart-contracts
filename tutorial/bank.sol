pragma solidity 0.7.5;

import "./ownable.sol";
import "./destroyable.sol";

interface GovernmentInterface {
    function addTransaction(address _from, address _to, uint _amount) external payable;
    
}

contract Bank is Ownable, Destroyable {
    
    GovernmentInterface governmentInstance = GovernmentInterface(0xcF037f9f75F35362Fc21e4CA879C8281AB53C39A);
    
    mapping(address => uint) balance;
    
    event depositDone(uint _amount, address indexed _depositedTo);
    event transferExecuted(uint _amount, address indexed _from, address indexed _to);
    
    function deposit() public payable returns(uint) {
        balance[msg.sender] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return balance[msg.sender];
    }
    
    function withdraw(uint _amount) public onlyOwner returns (uint) {
        // msg.sender is a payable address
        require(balance[msg.sender] >= _amount, "Balance not sufficient");
        balance[msg.sender] -= _amount;
        msg.sender.transfer(_amount);
        return balance[msg.sender];
    }
    
    function getBalance() public view returns (uint) {
        return balance[msg.sender];
    }
    
    function transfer(address _recipient, uint _amount) public {
        require(balance[msg.sender] >= _amount, "Balance not sufficient");
        require(msg.sender != _recipient, "Don't transfer money to yourself");
        
        uint previousSenderBalance = balance[msg.sender];
        
        _transfer(msg.sender, _recipient, _amount);
        
        governmentInstance.addTransaction(msg.sender, _recipient, _amount);
        
        emit transferExecuted(_amount, msg.sender, _recipient);
        
        assert(balance[msg.sender] == previousSenderBalance - _amount);
    }
    
    function _transfer(address _from, address _to, uint _amount) private {
        balance[_from] -= _amount;
        balance[_to] += _amount;
    }
}
