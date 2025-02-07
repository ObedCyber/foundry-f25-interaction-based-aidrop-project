# Interaction-Based Airdrop Smart Contract

## Overview

The **Interaction-Based Airdrop** is a smart contract that rewards users with tokens based on their interactions with a specific contract. This system ensures that only active participants receive the airdrop, making it a fairer and engagement-driven distribution model.

## Features

- **Eligibility-Based Airdrop**: Users must interact with a designated smart contract a specified number of times to qualify.
- **Automated Token Distribution**: Eligible users automatically receive tokens.
- **Configurable Interaction Threshold**: The contract owner can set the required number of interactions.
- **Fair & Transparent**: Only genuine interactions count toward eligibility.
- **Secure Execution**: Utilizes OpenZeppelin’s libraries for security.

## Prerequisites

To deploy and interact with this contract, ensure you have:

- **Node.js** (v16 or higher)
- [Foundry](https://book.getfoundry.sh/) installed
- **OpenZeppelin Contracts** for security and standard implementations
- **A deployed smart contract** that users must interact with to qualify

## Installation Steps

1. **Clone the repository and navigate to the project directory:**
   ```bash
   git clone https://github.com/ObedCyber/interaction-airdrop.git
   cd interaction-airdrop
   ```
2. **Install Foundry:** Follow the official Foundry installation guide [here](https://book.getfoundry.sh/getting-started/installation).
3. **Install dependencies:**
   ```bash
   forge install
   ```

## Smart Contract Details

### 1. **InteractionAirdrop.sol**

#### Key Functions:

- `recordInteraction(address user)`: Logs an interaction for a user.
- `checkEligibility(address user)`: Checks if the user has met the required interactions for the airdrop.
- `claimAirdrop()`: Allows eligible users to claim their airdrop reward.
- `setInteractionThreshold(uint256 newThreshold)`: Sets the required number of interactions for eligibility (owner only).
- `setAirdropAmount(uint256 newAmount)`: Updates the token amount to be airdropped (owner only).

#### Events:

- `InteractionRecorded(address indexed user, uint256 totalInteractions)`: Emitted when a user interacts with the target contract.
- `AirdropClaimed(address indexed user, uint256 amount)`: Emitted when a user claims their airdrop.
- `ThresholdUpdated(uint256 newThreshold)`: Emitted when the interaction requirement is updated.
- `AirdropAmountUpdated(uint256 newAmount)`: Emitted when the airdrop amount is updated.

#### Constructor Parameters:

- `_airdropToken`: Address of the ERC20 token being distributed.
- `_targetContract`: Address of the contract users must interact with.
- `_interactionThreshold`: Number of interactions required for eligibility.
- `_airdropAmount`: Amount of tokens rewarded per user.

---

## Usage

### 1. **Deploy Contracts**

Deploy the ERC20 token and the `InteractionAirdrop` contract:

```solidity
airdrop = new InteractionAirdrop(tokenAddress, targetContract, 5, 100 * 1e18);
```

### 2. **Record Interactions**

Each time a user interacts with the designated contract, call:

```solidity
airdrop.recordInteraction(msg.sender);
```

### 3. **Check Eligibility**

Users can check if they are eligible:

```solidity
airdrop.checkEligibility(userAddress);
```

### 4. **Claim Airdrop**

Eligible users can claim their tokens:

```solidity
airdrop.claimAirdrop();
```

### 5. **Update Thresholds (Owner Only)**

The owner can modify interaction requirements:

```solidity
airdrop.setInteractionThreshold(10);
airdrop.setAirdropAmount(200 * 1e18);
```

---

## Security Measures

- **Anti-Sybil Protections**: Prevents bots from spamming interactions.
- **Access Control**: Only the owner can modify thresholds and airdrop amounts.
- **Reentrancy Protection**: Ensures users can't claim multiple times unfairly.

## License

This project is licensed under the **MIT License**.

