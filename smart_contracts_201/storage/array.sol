pragma solidity 0.8.0;

contract StorageArray {
    struct Entity {
        uint data;
        address _address;
    }
    
    Entity[] public entities;
    
    function addEntity(uint _data) public returns(uint rowNumber) {
        Entity memory newEntity;
        newEntity._address = msg.sender;
        newEntity.data = _data;
        entities.push(newEntity);
        return entities.length - 1;
    }
    
    function updateEntity(uint _data) public returns(bool) {
        for (uint i = 0; i < entities.length; i++) {
            if (entities[i]._address == msg.sender) {
                entities[i].data = _data;
                return true;
            }
        }
        return false;
    }
    
    function getEntityCount() public view returns(uint) {
        return entities.length;
    }
}
