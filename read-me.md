Rich Products Frozen Food Supply Chain Traceability

A blockchain-based frozen food supply chain traceability system built on the Ethereum Sepolia Test Network using Solidity, Remix IDE, and MetaMask.  
This project ensures transparency, authenticity, and accountability across every stage of the supply chain — from farms to retailers — by recording immutable transactions on-chain.

---

Project Overview

The frozen food industry faces major challenges in tracking product quality, authenticity, and safety. Traditional systems lack transparency and are vulnerable to tampering.  
This project uses blockchain technology to build a **traceable and tamper-proof supply chain**, enabling all stakeholders to verify the origin, status, and movement of products.

---

Objectives

- Ensure full transparency and traceability in the frozen food supply chain.  
- Provide immutable records of every transaction and batch movement.  
- Enable role-based access for Farms, Distributors, Retailers, and Admins.  
- Implement a secure and automated **recall system** for faulty batches.  
- Enhance customer trust and safety through blockchain-backed verification.

---

Tech Stack & Frameworks Used

| Component | Tool / Framework |
|------------|------------------|
| **Blockchain Network** | Ethereum Sepolia Testnet |
| **Smart Contract Language** | Solidity v0.8.30 |
| **Development Environment** | Remix IDE |
| **Wallet** | MetaMask |
| **Test ETH Source** | Google Cloud Faucet |
| **Frontend (Future Scope)** | React.js for DApp interface |

---

 Smart Contract Features

-Participant Registration: Admin can register farms, distributors, and retailers.  
- Batch Creation: Farms can create product batches with unique lot codes.  
-Ownership Transfer: Products can be transferred between registered participants.  
- Recall Mechanism: Admin can recall any batch by lot code for safety.  
-Traceability: View complete batch history and current status on-chain.  
-Event Logging: Every transaction (creation, transfer, recall) emits an event for transparency.

---

## 🧾 Contract Workflow

| Step | Function | Role | Description |
|------|-----------|------|-------------|
| 1️⃣ | `registerParticipant()` | Admin | Registers new participants |
| 2️⃣ | `createBatch()` | Farm | Creates a product batch |
| 3️⃣ | `transferBatch()` | Farm → Distributor | Transfers ownership |
| 4️⃣ | `triggerRecall()` | Admin | Recalls affected lot codes |
| 5️⃣ | `getProductStatus()` | Anyone | Checks current batch status |
| 6️⃣ | `getProductHistory()` | Anyone | Retrieves complete batch history |

---

Deployment & Testing

- Contract deployed via **Remix IDE** connected to **MetaMask** (`Injected Provider`).  
- Network: **Ethereum Sepolia Testnet (Chain ID: 11155111)**  
- Test ETH obtained from **Google Cloud Faucet**.  
- Functions tested: `registerParticipant()`, `createBatch()`, `transferBatch()`, `triggerRecall()`, `getProductStatus()`, `getProductHistory()`.  
- All transactions successfully executed and verified through **Remix logs** and **MetaMask confirmations**.

---

Future Enhancements

- Integrate with IoT sensors (temperature and logistics data).  
- Add a web-based dashboard using React.js for user-friendly interaction.  
- Incorporate QR code scanning for product verification by end users.  
- Store additional metadata like expiry dates and temperature logs on-chain.

---

