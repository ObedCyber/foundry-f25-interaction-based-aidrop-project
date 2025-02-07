// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {AirdropContract} from "../../src/AirdropContract.sol";
import {AirdropToken} from "../../src/AirdropToken.sol";
import {InteractionContract} from "../../src/InteractionContract.sol";
import {DeployAirdropContract} from "../../script/DeployAirdropContract.s.sol";

contract AirdropContractTest is Test {
    AirdropToken public airdropToken;
    InteractionContract public interactionContract;
    AirdropContract public airdropContract;
    DeployAirdropContract public deployer;
    address supplyHolder;

    address public USER = makeAddr("user");
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public interactionThreshold;
    uint256 public startTime;
    uint256 public endTime;

    error InteractionContract_RateLimitExceeded();
    error AirdropContract_AirdropNotActive();
    error EnforcedPause();

    address contractOwner = vm.envAddress("LOCAL_ADDRESS");

    function setUp() public {
        deployer = new DeployAirdropContract();
        (airdropToken, supplyHolder, interactionContract, airdropContract, interactionThreshold, startTime, endTime) = deployer.run();

        // Mint tokens to the user for testing
        vm.prank(supplyHolder);
        airdropToken.transfer(USER, STARTING_BALANCE);

        // Approve the contract to spend tokens on behalf of the user
        vm.startPrank(USER);
        airdropToken.approve(address(airdropContract), type(uint256).max);
        vm.stopPrank();
    }
    modifier userhasInteracted {
        uint256 requiredInteractions = interactionThreshold;
        for (uint256 i = 0; i < requiredInteractions; i++) {
            vm.warp(block.timestamp + 7 hours); // Bypass rate limit
            vm.prank(USER);
            interactionContract.interact();
        }
        _;
    }

    /// @dev Test that the constructor initializes the contract correctly
    function testConstructorInitialization() public view {
        assertEq(address(airdropContract.rewardToken()), address(airdropToken), "Reward token mismatch");
        assertEq(airdropContract.interactionContract(), address(interactionContract), "Interaction contract mismatch");
        assertEq(airdropContract.interactionThreshold(), interactionThreshold, "Interaction threshold mismatch");
        assertEq(airdropContract.startTime(), startTime, "Start time mismatch");
        assertEq(airdropContract.endTime(), endTime, "End time mismatch");
    }

    /// @dev Test that userBaseReward calculates rewards correctly
    function testUserBaseRewardCalculation() public {
        uint256 rewardFor5Interactions = airdropContract.userBaseReward(5);
        uint256 rewardFor10Interactions = airdropContract.userBaseReward(10);
        uint256 rewardFor20Interactions = airdropContract.userBaseReward(20);

        assertEq(rewardFor5Interactions, 10, "Incorrect reward for 5 interactions");
        assertEq(rewardFor10Interactions, 30, "Incorrect reward for 10 interactions");
        assertEq(rewardFor20Interactions, 45, "Incorrect reward for 20 interactions");
    }
    
    /// @dev Test user interaction count with rate limiting
   function testInteractionRateLimiting() public {
    // First interaction
    vm.prank(USER);
    interactionContract.interact();

    // Warp time forward by 5 hours (less than cooldown period)
    uint256 currentTime = block.timestamp; // Save the current timestamp
    vm.warp(currentTime + 5 hours); // Warp time forward by 5 hours

    // Attempt second interaction (should fail due to rate limit)
    vm.expectRevert(abi.encodeWithSelector(InteractionContract_RateLimitExceeded.selector));
    vm.prank(USER);
    interactionContract.interact();

     // Warp time forward by 1 more hour (total 6 hours)
    vm.warp(currentTime + 6 hours); // Warp time forward to exactly 6 hours after the first interaction

    // Second interaction should now succeed
    vm.prank(USER);
    interactionContract.interact();
}

/// @dev Test user eligibility based on interaction count
    function testUserEligibility() public {
        // User has not interacted enough
        assertFalse(airdropContract.checkEligibility(USER), "User should not be eligible");

        // User interacts enough to meet the threshold
        uint256 requiredInteractions = interactionThreshold;
        for (uint256 i = 0; i < requiredInteractions; i++) {
            vm.warp(block.timestamp + 7 hours); // Bypass rate limit
            vm.prank(USER);
            interactionContract.interact();
        }

        assertTrue(airdropContract.checkEligibility(USER), "User should be eligible");
    }

    /// @dev Test reward calculation based on interaction count
    function testRewardCalculation() public {
        uint256 interactions = 10; // Example interaction count
        vm.prank(USER);
        for (uint256 i = 0; i < interactions; i++) {
            vm.warp(block.timestamp + 7 hours); // Bypass rate limit
            interactionContract.interact();
        }

        uint256 expectedReward = interactions * airdropContract.userBaseReward(interactions);
        assertEq(expectedReward, 300, "Reward calculation mismatch"); // 10 interactions × 30 base reward
    }

    /// @dev Test claiming rewards
    function testClaimReward() public userhasInteracted(){
         uint256 requiredInteractions = interactionThreshold;

        // Claim rewards
        uint256 initialBalance = airdropToken.balanceOf(USER);
        vm.prank(USER);
        airdropContract.checkEligibility(USER);
        vm.prank(USER);
        airdropContract.claimReward();

        uint256 finalBalance = airdropToken.balanceOf(USER);
        uint256 expectedReward = requiredInteractions * airdropContract.userBaseReward(requiredInteractions);
        assertEq(finalBalance, initialBalance - expectedReward, "Reward claim failed");
    }

    /// @dev Test claiming rewards outside the airdrop time range
    function testClaimRewardOutsideTimeRange() public userhasInteracted() {
        vm.warp(endTime + 1); // Warp time past the end time

        // Attempt to claim rewards
        vm.expectRevert(abi.encodeWithSelector(AirdropContract_AirdropNotActive.selector));
        vm.prank(USER);
        airdropContract.claimReward();
    }

    /// @dev Test pausing and unpausing the airdrop
    function testPauseUnpauseAirdrop() public {
        // Pause the airdrop
        vm.prank(contractOwner);
        airdropContract.pauseAirdrop();
        assertTrue(airdropContract.paused(), "Airdrop should be paused");

        // Attempt to claim rewards while paused
        vm.expectRevert(abi.encodeWithSelector(EnforcedPause.selector));
        vm.prank(USER);
        airdropContract.claimReward();

        // Unpause the airdrop
        vm.prank(contractOwner);
        airdropContract.unpauseAirdrop();
        assertFalse(airdropContract.paused(), "Airdrop should be unpaused");
    }

    
}


