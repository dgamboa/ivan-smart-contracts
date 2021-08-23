pragma solidity 0.7.5;
pragma abicoder v2;

// @title: Multi-sig wallet
// @author: Daniel Gamboa

contract Wallet {
    address[] public owners;
    uint limit;
    
    struct Transfer {
        uint amount;
        address payable receiver;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }
    
    event transferRequestCreated(uint _id, uint _amount, address _initiator, address _receiver);
    event ApprovalReceived(uint _id, uint _approvals, address _approver);
    event TransferApproved(uint _id);
    
    Transfer[] transferRequests;
    
    mapping(address => mapping(uint => bool)) approvals;
    
    // Only allows wallet owners to continue execution
    modifier onlyOwners() {
        bool owner = false;
        
        for (uint i=0; i<owners.length; i++) {
            if (owners[i] == msg.sender) {
                owner = true;
                break;
            }
        }
        
        require(owner == true);
        _;
    }
    
    // Initializes the owners list and the limit
    constructor(address[] memory _owners, uint _limit) {
        owners = _owners;
        limit = _limit;
    }
    
    // Allows anyone to deposit funds into the wallet
    function deposit() public payable {}
    
    // Creates a transfer and adds it to the transferRequests queue
    function createTransfer(uint _amount, address payable _receiver) public onlyOwners {
        transferRequests.push(
            Transfer(_amount, _receiver, 0, false, transferRequests.length)
        );
        
        emit transferRequestCreated(transferRequests.length - 1, _amount, msg.sender, _receiver);
    }
    
    // Sets up approval for one of the transfer requests
    // Updates the Transfer object
    // Updates the mapping for approval
    // When a Transfer has been approved by the limit number of owners, this function sends the transfer to the recipient
    // An owner votes only once
    // It doesn't allow owners to vote on sent transfers
    function approve(uint _id) public onlyOwners {
        require(transferRequests[_id].hasBeenSent == false);
        require(approvals[msg.sender][_id] == false);
        
        transferRequests[_id].approvals++;
        approvals[msg.sender][_id] = true;
        
        emit ApprovalReceived(_id, transferRequests[_id].approvals, msg.sender);
        
        if (transferRequests[_id].approvals >= limit) {
            transferRequests[_id].hasBeenSent = true;
            transferRequests[_id].receiver.transfer(transferRequests[_id].amount);
            emit TransferApproved(_id);
        }
        
    }
    
    // Returns all transfer requests
    function getTransferRequests() public view returns (Transfer[] memory) {
        return transferRequests;
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
