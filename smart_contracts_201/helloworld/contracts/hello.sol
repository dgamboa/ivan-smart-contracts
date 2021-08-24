pragma solidity 0.8.0;

contract Helloworld {
  string message = "Hello World";

  function setMessage(string memory newMessage) 
           public
           returns (string memory)
  {
    message = newMessage;
    return message;
  }

  function hello() public view returns (string memory) {
    return message;
  }
}
