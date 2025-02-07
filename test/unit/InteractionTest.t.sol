// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {InteractionContract} from "../../src/InteractionContract.sol";
import {DeployInteraction} from "../../script/DeployInteraction.s.sol";

contract InteractionTest is Test {
    InteractionContract public interaction;
    DeployInteraction public deployer;
    address public USER = makeAddr("user");

    function setUp() public {
        deployer = new DeployInteraction();
        interaction = deployer.run();
    }

    function testUserInteractions() public {
        vm.startPrank(USER);
        interaction.interact();
        interaction.interact();
        interaction.interact();
        vm.stopPrank();

        uint256 usersInteraction = interaction.getInteractionCount(USER);
        assertEq(usersInteraction, 3);
    }

    function testUserInteractionEmitEvent() public {
        vm.expectEmit(true, true, true, true);
        emit InteractionContract.UserHasInteracted(USER,1);

        vm.startPrank(USER);
        interaction.interact();
        vm.stopPrank();
    }
    
}
