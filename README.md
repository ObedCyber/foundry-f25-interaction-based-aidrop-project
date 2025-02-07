# Interaction-Based Airdrop Project

## Overview

The **Interaction-Based Airdrop Project** is a decentralized system that rewards users with tokens based on their interactions with an external contract. The project integrates three smart contracts:

1\. **AirdropContract.sol**: Manages the airdrop logic, including user eligibility, reward calculation, and claim mechanics.

2\. **InteractionContract.sol**: Tracks user interactions and enforces rate limits to prevent abuse.

3\. **AirdropToken.sol**: A custom ERC20 token (`MTK`) used as the reward currency.

## Features

- **Interaction-Based Rewards**: Users earn rewards proportional to their number of interactions with the `InteractionContract`.

- **Dynamic Reward Tiers**: Rewards are calculated based on the user's interaction count (e.g., 10 tokens for 1--5 interactions, 30 tokens for 6--15 interactions, etc.).

- **Rate Limiting**: Prevents users from spamming interactions by enforcing a cooldown period between interactions.

- **Time-Limited Airdrop**: The airdrop is active only within a specified time window.

- **Pause Functionality**: Administrators can pause the airdrop in case of emergencies.

- **Reentrancy Protection**: Ensures secure transactions using OpenZeppelin's `ReentrancyGuard`.

- **Access Control**: Administrative functions are restricted to the contract owner using OpenZeppelin's `Ownable`.

## Prerequisites

To deploy and interact with this project, you will need:

- **Node.js** (v16 or higher)

- [Foundry](https://book.getfoundry.sh/) installed

- **OpenZeppelin Contracts** for security and standard implementations

- **Forge-Std Library** for debugging and testing

### Installation Steps

1\. **Clone the repository and navigate to the project directory:**

   ```bash

   git clone https://github.com/your-repo/foundry-interaction-based-airdrop.git

   cd foundry-interaction-based-airdrop

   ```

2\. **Install Foundry:**

   Follow the official Foundry installation guide [here](https://book.getfoundry.sh/getting-started/installation).

3\. **Install dependencies:**

   ```bash

   forge install

   ```

## Core Contracts and Functions

### 1. **AirdropContract.sol**

#### Key Functions:

- `userBaseReward(uint256 userInteractionCount)`: Calculates the base reward for a user based on their interaction count.

- `checkEligibility(address user)`: Checks if a user is eligible for the airdrop based on their interaction count and claim status.

- `claimReward()`: Allows eligible users to claim their rewards during the airdrop's active period.

- `pauseAirdrop()` / `unpauseAirdrop()`: Admin functions to pause or unpause the airdrop.

#### Constructor Parameters:

- `_rewardToken`: Address of the ERC20 token used for rewards.

- `_interactionContract`: Address of the `InteractionContract` for tracking interactions.

- `_interactionThreshold`: Minimum number of interactions required for eligibility.

- `_startTime` / `_endTime`: Timestamps defining the airdrop's active period.

---

### 2. **InteractionContract.sol**

#### Key Functions:

- `interact()`: Allows users to interact with the contract. Enforces a cooldown period to limit the rate of interactions.

- `getInteractionCount(address user)`: Retrieves the total number of interactions for a specific user.

#### Constructor Parameters:

- None (default cooldown period is set to 6 hours).

#### Events:

- `UserHasInteracted`: Emitted when a user successfully interacts with the contract.

---

### 3. **AirdropToken.sol**

#### Key Functions:

- `constructor(string memory name, string memory symbol, uint256 initialSupply)`: Initializes the token with a name, symbol, and initial supply.

- `mint(address to, uint256 amount)`: Mints new tokens to a specified address (restricted to the contract owner).

#### Token Details:

- Name: `AirdropToken`

- Symbol: `MTK`

---

### Key Enums and State Variables:

- **`mapping(address => bool) isEligible`**: Tracks whether a user is eligible for the airdrop.

- **`mapping(address => bool) hasClaimed`**: Tracks whether a user has already claimed their reward.

- **`uint256 interactionThreshold`**: Minimum number of interactions required for eligibility.

- **`uint256 startTime` / `uint256 endTime`**: Defines the airdrop's active period.

---

## Usage

1\. **Deploy Contracts**:

   - Deploy `AirdropToken.sol` with an initial supply.

   - Deploy `InteractionContract.sol`.

   - Deploy `AirdropContract.sol` with the addresses of the above contracts and configuration parameters.

2\. **Interact with the System**:

   - Users interact with the `InteractionContract` to increase their interaction count.

   - Eligible users can call `claimReward()` during the airdrop's active period to receive their rewards.

3\. **Admin Management**:

   - Set the airdrop's start and end times.

   - Pause or unpause the airdrop as needed.

4\. **Example Workflow**:

   ```solidity

   // User interacts with the InteractionContract

   interactionContract.interact();

   // Check eligibility

   bool isEligible = airdropContract.checkEligibility(user);

   // Claim reward if eligible

   if (isEligible) {

       airdropContract.claimReward();

   }

   ```

## Security

- **Reentrancy Protection**: Prevents malicious reentrant calls during reward claims.

- **Access Control**: Only the owner can manage administrative functions (e.g., pausing/unpausing the airdrop).

- **Error Handling**: Reverts with custom errors for invalid operations, insufficient balance, or out-of-time claims.

## License

This project is licensed under the **MIT License**.
