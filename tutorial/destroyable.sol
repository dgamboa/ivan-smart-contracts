pragma solidity 0.7.5;

import "./ownable.sol";

contract Destroyable is Ownable {
    
    function destroy() public onlyOwner {
        address payable receiver = msg.sender;
        selfdestruct(receiver);
    }
}
