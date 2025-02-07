// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {console} from "forge-std/console.sol";

contract InteractionContract {
    /** Errors */
    error InteractionContract_RateLimitExceeded();

    uint256 cooldownPeriod = 6 * 60 * 60; // 6 hours = 21,600 seconds

    /** To keep records of the users and their number of interactions */
    mapping(address => uint256) public interactionCount;
    mapping(address => uint256) public lastInteractionTime;

    event UserHasInteracted(address indexed user, uint256 totalInteractions);

    /*  function interact() external {
        interactionCount[msg.sender]++;
        if(block.timestamp < (lastInteractionTime[msg.sender] + cooldownPeriod))
        {
            revert InteractionContract_RateLimitExceeded();
        }
        lastInteractionTime[msg.sender] = block.timestamp;
        emit UserHasInteracted(msg.sender, interactionCount[msg.sender]);
    } */

    function interact() external {
    
        if (
            lastInteractionTime[msg.sender] != 0 &&
            block.timestamp < (lastInteractionTime[msg.sender] + cooldownPeriod)
        ) {
            revert InteractionContract_RateLimitExceeded();
        }
        interactionCount[msg.sender]++;
        lastInteractionTime[msg.sender] = block.timestamp;
        emit UserHasInteracted(msg.sender, interactionCount[msg.sender]);
    }

    /**getter functions */
    function getInteractionCount(address user) external view returns (uint256) {
        return interactionCount[user];
    }
}
