// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title RichProductsSupplyChain
 * @dev A smart contract to manage the traceability of a frozen food supply chain.
 * This contract includes participant registration, lot-level batch tracking,
 * and a smart contract-powered recall system.
 * NOTE FOR PROJECT: For a real-world enterprise solution, this contract's logic
 * would be deployed on a permissioned blockchain like Hyperledger Fabric to enforce
 * the required data privacy (e.g., using Channels). In this public blockchain
 * simulation (Remix), all data is transparent for demonstration purposes.
 */
contract RichProductsSupplyChain {

    //===========
    // STATE VARIABLES
    //===========

    address public admin; // The address of the contract administrator (e.g., Rich Products)

    // Enums to define roles and product status, making the code more readable
    enum Role { Unassigned, Farm, Manufacturer, Distributor, Retailer }
    enum Status { Good, Hold, Recalled, Destroyed }

    // Struct to define a participant in the supply chain
    struct Participant {
        string name;
        Role role;
        bool isRegistered;
    }

    // Struct to define a single step in a product's history
    struct HistoryEntry {
        uint256 timestamp;
        address participantAddress;
        string participantName;
        Status status;
        string action; // e.g., "Created", "Transferred", "Recalled"
    }

    // Struct to define a batch of products, identified by a unique ID
    struct ProductBatch {
        uint256 productId;
        string lotCode;
        Status status;
        address currentOwner;
        HistoryEntry[] history; // An array to store the full journey of the batch
    }

    // Mappings to store data on the blockchain
    mapping(address => Participant) public participants; // Maps an address to a Participant struct
    mapping(uint256 => ProductBatch) public productBatches; // Maps a unique product ID to a ProductBatch struct
    mapping(string => uint256[]) public lotCodeToProductIds; // Maps a lot code to an array of product IDs

    uint256 public nextProductId = 1; // Counter to ensure unique product IDs

    //===========
    // EVENTS
    //===========

    event ParticipantRegistered(address indexed participantAddress, string name, Role role);
    event BatchCreated(uint256 indexed productId, string lotCode, address indexed creator);
    event BatchTransferred(uint256 indexed productId, address indexed from, address indexed to);
    event BatchRecalled(string lotCode, address indexed triggeredBy);

    //===========
    // MODIFIERS
    //===========

    // Modifier to restrict a function to be callable only by the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    // Modifier to ensure the caller is a registered participant
    modifier onlyRegisteredParticipant() {
        require(participants[msg.sender].isRegistered, "Caller is not a registered participant.");
        _;
    }

    //===========
    // CONSTRUCTOR
    //===========

    constructor() {
        // Set the contract deployer as the initial administrator
        admin = msg.sender;
        // Register the admin as the first participant (Manufacturer)
        participants[admin] = Participant("Rich Products (Admin)", Role.Manufacturer, true);
        emit ParticipantRegistered(admin, "Rich Products (Admin)", Role.Manufacturer);
    }

    //===========
    // PARTICIPANT FUNCTIONS
    //===========

    /**
     * @dev Register a new participant in the supply chain. Only admin can do this.
     * @param _participantAddress The Ethereum address of the new participant.
     * @param _name The name of the participant (e.g., "Fresh Catch Fisheries").
     * @param _role The role of the participant (e.g., Farm, Distributor).
     */
    function registerParticipant(address _participantAddress, string memory _name, Role _role) public onlyAdmin {
        require(!participants[_participantAddress].isRegistered, "Participant is already registered.");
        participants[_participantAddress] = Participant(_name, _role, true);
        emit ParticipantRegistered(_participantAddress, _name, _role);
    }

    //===========
    // CORE SUPPLY CHAIN FUNCTIONS
    //===========

    /**
     * @dev Create a new batch of products. Can only be done by a 'Farm'.
     * @param _lotCode The 8-digit lot code for this new batch.
     */
    function createBatch(string memory _lotCode) public onlyRegisteredParticipant {
        require(participants[msg.sender].role == Role.Farm, "Only Farms can create new batches.");

        uint256 productId = nextProductId;
        ProductBatch storage newBatch = productBatches[productId];
        newBatch.productId = productId;
        newBatch.lotCode = _lotCode;
        newBatch.status = Status.Good;
        newBatch.currentOwner = msg.sender;

        // Add the first history entry
        newBatch.history.push(HistoryEntry({
            timestamp: block.timestamp,
            participantAddress: msg.sender,
            participantName: participants[msg.sender].name,
            status: Status.Good,
            action: "Batch Created"
        }));

        lotCodeToProductIds[_lotCode].push(productId);
        nextProductId++;
        emit BatchCreated(productId, _lotCode, msg.sender);
    }

    /**
     * @dev Transfer a product batch to another participant.
     * @param _productId The unique ID of the product batch to transfer.
     * @param _newOwner The address of the participant receiving the batch.
     */
    function transferBatch(uint256 _productId, address _newOwner) public onlyRegisteredParticipant {
        ProductBatch storage batch = productBatches[_productId];
        require(batch.currentOwner == msg.sender, "You are not the current owner of this batch.");
        require(participants[_newOwner].isRegistered, "The new owner is not a registered participant.");
        require(batch.status == Status.Good, "Cannot transfer a batch that is not in 'Good' status.");

        batch.currentOwner = _newOwner;

        // Add a new history entry for the transfer
        batch.history.push(HistoryEntry({
            timestamp: block.timestamp,
            participantAddress: _newOwner,
            participantName: participants[_newOwner].name,
            status: Status.Good,
            action: "Transferred"
        }));

        emit BatchTransferred(_productId, msg.sender, _newOwner);
    }

    //===========
    // INNOVATION: RECALL SYSTEM
    //===========

    /**
     * @dev Trigger a recall for all products associated with a specific lot code. Admin only.
     * @param _lotCode The lot code of the products to be recalled.
     */
    function triggerRecall(string memory _lotCode) public onlyAdmin {
        uint256[] memory productIds = lotCodeToProductIds[_lotCode];
        require(productIds.length > 0, "No products found for this lot code.");

        for (uint i = 0; i < productIds.length; i++) {
            ProductBatch storage batch = productBatches[productIds[i]];

            // Only recall batches that are not already recalled or destroyed
            if (batch.status == Status.Good || batch.status == Status.Hold) {
                batch.status = Status.Recalled;

                // Add a history entry for the recall action
                batch.history.push(HistoryEntry({
                    timestamp: block.timestamp,
                    participantAddress: admin,
                    participantName: "Rich Products (Admin)",
                    status: Status.Recalled,
                    action: "Product Recalled"
                }));
            }
        }
        emit BatchRecalled(_lotCode, msg.sender);
    }

    //===========
    // TRACEABILITY / GETTER FUNCTIONS
    //===========

    /**
     * @dev Get the current status of a product. This is a public view function for consumers.
     * @param _productId The unique ID of the product batch.
     * @return The current status of the batch (Good, Recalled, etc.).
     */
    function getProductStatus(uint256 _productId) public view returns (Status) {
        return productBatches[_productId].status;
    }

    /**
     * @dev Get the full traceability history for a product. Public view for consumers.
     * @param _productId The unique ID of the product batch.
     * @return An array of history entries detailing the product's journey.
     */
    function getProductHistory(uint256 _productId) public view returns (HistoryEntry[] memory) {
        return productBatches[_productId].history;
    }
}