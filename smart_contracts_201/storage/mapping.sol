pragma solidity 0.8.0;

contract StorageMapping {
    struct Entity {
        uint data;
        address _address;
    }
    
    mapping(address => Entity) public entities;
    
    function addEntity(uint _data) public returns(bool) {
        Entity memory newEntity;
        newEntity._address = msg.sender;
        newEntity.data = _data;
        entities[msg.sender] = newEntity;
        return true;
    }
    
    function updateEntity(uint _data) public returns(bool) {
        Entity memory entityToUpdate;
        entityToUpdate = entities[msg.sender];
        entityToUpdate.data = _data;
        entities[msg.sender] = entityToUpdate;
        return true;
    }
}
