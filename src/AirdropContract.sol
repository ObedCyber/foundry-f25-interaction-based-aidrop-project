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

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {InteractionContract} from "./InteractionContract.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {console} from "forge-std/console.sol";


contract AirdropContract is Pausable, Ownable, ReentrancyGuard {
    /**Errors */
    error AirdropContract_UserNotEligible();
    error AirdropContract_UserHasClaimed();
    error AirdropContract_TransferFailed();
    error AirdropContract_InvalidTimeRange();
    error AirdropContract_AirdropNotActive();

    IERC20 public rewardToken;
    address public interactionContract;
    uint256 public interactionThreshold;
    uint256 public baseReward;

    uint256 public startTime;
    uint256 public endTime;

    mapping(address => bool) public isEligible;
    mapping(address => bool) public hasClaimed;

    constructor(
        address _rewardToken,
        address _interactionContract,
        uint256 _interactionThreshold, 
        uint256 _startTime,
        uint256 _endTime
    ) Ownable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) {
        rewardToken = (IERC20(_rewardToken));
        interactionContract = _interactionContract;
        interactionThreshold = _interactionThreshold;
        startTime = _startTime;
        endTime = _endTime;

        if(startTime > endTime)
        {
            revert AirdropContract_InvalidTimeRange();
        }
    }

    function userBaseReward(uint256 userInteractionCount) public returns(uint256)
    {
        if(userInteractionCount <= 5)
        {
            baseReward = 10;
        }
        if(userInteractionCount <= 15 && userInteractionCount > 5)
        {
            baseReward = 30;
        }
        if(userInteractionCount > 15)
        {
            baseReward = 45;
        }

        return baseReward;
    }

    /**User checks eligibility */
    function checkEligibility(address user) public returns(bool){
        uint256 userInteractionCount = InteractionContract(interactionContract).getInteractionCount(user);
        console.log("user's address from eligibility:", user);
        /* console.log("user interaction:", userInteractionCount);
        console.log("Interaction threshold:", interactionThreshold);
        console.log("Is this user eligible?:", isEligible[user]); */
        if(userInteractionCount >= interactionThreshold && !hasClaimed[user])
        {
            isEligible[user] = true;
            return true;
        }
        else {
            isEligible[user] = false;
            return false;
        }
    }

    function claimReward() external whenNotPaused nonReentrant{
        uint256 userInteractionCount = InteractionContract(interactionContract).getInteractionCount(msg.sender);

/*         console.log("user's interaction:", userInteractionCount);
        console.log("Interaction threshold:", interactionThreshold);
        console.log("Is this user eligible?:", checkEligibility(msg.sender));
        console.log("user address from claimreward:", address(msg.sender)); */
        // checks
        if(checkEligibility(msg.sender) != true)
        {
            revert AirdropContract_UserNotEligible();
        }
        if(hasClaimed[msg.sender] == true)
        {
            revert AirdropContract_UserHasClaimed();
        }
        if (block.timestamp < startTime || block.timestamp > endTime) {
            revert AirdropContract_AirdropNotActive();
        }
        // Effects
        hasClaimed[msg.sender] = true;

        // Interactions
        //uint256 userInteractionCount = InteractionContract(interactionContract).getInteractionCount(msg.sender);
        uint256 rewardAmount = userInteractionCount * userBaseReward(userInteractionCount);

        bool success = rewardToken.transferFrom(msg.sender, address(this), rewardAmount);
            if(!success) {
                revert AirdropContract_TransferFailed();      
            }

        
    }

    /// @dev Admin function to pause the airdrop
    function pauseAirdrop() external onlyOwner {
        _pause();
    }

    /// @dev Admin function to unpause the airdrop
    function unpauseAirdrop() external onlyOwner {
        _unpause();
    }
}



















