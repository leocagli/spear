// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Spear - Contrato compatible con Polkadot via Moonbeam/Moonriver
contract SpearEscrow {
    enum EscrowStatus { Created, Funded, Completed, Disputed }
    
    struct Escrow {
        address client;
        address freelancer;
        uint256 amount;
        string description;
        EscrowStatus status;
        uint256 createdAt;
        uint256 yieldGenerated;
    }
    
    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCounter;
    address public admin;
    
    // Yield farming integration (mock for Polkadot DeFi)
    uint256 public constant YIELD_RATE = 5; // 0.05% per day
    
    event EscrowCreated(uint256 indexed escrowId, address indexed client, address indexed freelancer, uint256 amount);
    event PaymentReleased(uint256 indexed escrowId, address indexed freelancer, uint256 amount, uint256 yield);
    event YieldGenerated(uint256 indexed escrowId, uint256 yieldAmount);
    
    modifier onlyClient(uint256 escrowId) {
        require(msg.sender == escrows[escrowId].client, "Only client");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function createEscrow(address _freelancer, string memory _description) external payable {
        require(msg.value > 0, "Amount > 0");
        require(_freelancer != address(0), "Invalid freelancer");
        
        escrowCounter++;
        escrows[escrowCounter] = Escrow({
            client: msg.sender,
            freelancer: _freelancer,
            amount: msg.value,
            description: _description,
            status: EscrowStatus.Funded,
            createdAt: block.timestamp,
            yieldGenerated: 0
        });
        
        emit EscrowCreated(escrowCounter, msg.sender, _freelancer, msg.value);
    }
    
    function releasePayment(uint256 _escrowId) external onlyClient(_escrowId) {
        Escrow storage escrow = escrows[_escrowId];
        require(escrow.status == EscrowStatus.Funded, "Not funded");
        
        // Calculate yield (mock Polkadot DeFi integration)
        uint256 timeElapsed = block.timestamp - escrow.createdAt;
        uint256 yield = (escrow.amount * YIELD_RATE * timeElapsed) / (100 * 86400);
        escrow.yieldGenerated = yield;
        
        escrow.status = EscrowStatus.Completed;
        
        // Transfer principal + yield to freelancer
        uint256 totalAmount = escrow.amount + yield;
        payable(escrow.freelancer).transfer(totalAmount);
        
        emit PaymentReleased(_escrowId, escrow.freelancer, escrow.amount, yield);
    }
    
    function getEscrow(uint256 _escrowId) external view returns (
        address client,
        address freelancer,
        uint256 amount,
        string memory description,
        EscrowStatus status,
        uint256 yieldGenerated
    ) {
        Escrow memory escrow = escrows[_escrowId];
        return (escrow.client, escrow.freelancer, escrow.amount, escrow.description, escrow.status, escrow.yieldGenerated);
    }
}