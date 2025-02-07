// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {AirdropToken} from "../../src/AirdropToken.sol";
import {DeployAirdropToken} from "../../script/DeployAirdropToken.s.sol";
import {console} from "forge-std/console.sol";

contract AirdorpTokenTest is Test {
    AirdropToken public airdropToken;
    DeployAirdropToken public deployer;
    address supplyHolder;

    address public USER = makeAddr("user");
    address public RECIPIENT = makeAddr("recipient");
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant TRANSFER_AMOUNT = 10 ether;

    function setUp() public {
        deployer = new DeployAirdropToken();
        (airdropToken, supplyHolder) = deployer.run();

        // simulating the contract address holding the initial supply to transfer some tokens to User
        vm.startBroadcast(supplyHolder); 
        airdropToken.transfer(USER, STARTING_BALANCE); 
        vm.stopBroadcast();  
    }

function testUserBalance() public view{
        uint256 userBalance = airdropToken.balanceOf(USER);
        assertEq(userBalance, STARTING_BALANCE);
    }
    /**
     * @dev Verifies that transferring tokens reduces the sender’s balance and increases the recipient's balance correctly.
     */
    function testUserMakesTransferAndBalanceIsReduced() public {
        vm.startPrank(USER);
        airdropToken.transfer(RECIPIENT, TRANSFER_AMOUNT);
        vm.stopPrank();

        uint256 userBalance = airdropToken.balanceOf(USER);
        uint256 recipientBalance = airdropToken.balanceOf(RECIPIENT);
        assertEq(userBalance, STARTING_BALANCE - TRANSFER_AMOUNT);
        assertEq(recipientBalance, TRANSFER_AMOUNT);
    }

    /**
     * @dev Confirms that the total token supply remains the same after a transfer.
     */
     function testTotalSupplyRemainsConstantAfterTransfer() public {
        uint256 initialSupply = airdropToken.totalSupply();

        vm.startPrank(USER);
        airdropToken.transfer(RECIPIENT, TRANSFER_AMOUNT);
        vm.stopPrank();

        uint256 finalSupply = airdropToken.totalSupply();
        assertEq(finalSupply, initialSupply);
    }

    /**
     * @dev Checks that calling approve correctly sets the allowance for a spender.
     * allowance is the amount which _spender(RECIPIENT) is still allowed to withdraw from _owner(USER).
     */
     function testAllowanceIncreasesAfterApproval() public {
        uint256 approveAmount = 50 ether;

        vm.startPrank(USER);
        airdropToken.approve(RECIPIENT, approveAmount);
        vm.stopPrank();

        uint256 allowance = airdropToken.allowance(USER, RECIPIENT);
        assertEq(allowance, approveAmount);
    }

    /**
     * @dev Verifies that transferFrom works as expected when the recipient has sufficient allowance, and updates the remaining allowance accurately.
     */
     function testTransferFromWithAllowance() public {
        uint256 approveAmount = 50 ether;

        // User approves RECIPIENT to spend approveAmount on their behalf
        vm.startPrank(USER);
        airdropToken.approve(RECIPIENT, approveAmount);
        vm.stopPrank();

        // RECIPIENT calls transferFrom on behalf of USER
        vm.startPrank(RECIPIENT);
        airdropToken.transferFrom(USER, RECIPIENT, TRANSFER_AMOUNT);
        vm.stopPrank();

        uint256 userBalance = airdropToken.balanceOf(USER);
        uint256 recipientBalance = airdropToken.balanceOf(RECIPIENT);
        uint256 remainingAllowance = airdropToken.allowance(USER, RECIPIENT);

        assertEq(userBalance, STARTING_BALANCE - TRANSFER_AMOUNT);
        assertEq(recipientBalance, TRANSFER_AMOUNT);
        assertEq(remainingAllowance, approveAmount - TRANSFER_AMOUNT);
    }
    /**
     * @dev Ensures that transferring more tokens than the sender’s balance will revert.
    */
    function testTransferFailsWhenSenderHasInsufficientBalance() public {
        vm.expectRevert();
        
        vm.startPrank(USER);
        airdropToken.transfer(RECIPIENT, STARTING_BALANCE + 1 ether); // Exceeds balance
        vm.stopPrank();
    }

    /**
     * @dev Verifies that the allowance function correctly returns the approved amount for a spender.
    */
    function testApproveAndAllowanceCheck() public {
        uint256 approveAmount = 20 ether;

        vm.startPrank(USER);
        airdropToken.approve(RECIPIENT, approveAmount);
        vm.stopPrank();

        uint256 allowance = airdropToken.allowance(USER, RECIPIENT);
        assertEq(allowance, approveAmount);
    }
}