// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {InteractionContract} from "../src/InteractionContract.sol";

contract DeployInteraction is Script {
    function setUp() public {}

    function run() public returns(InteractionContract){
        vm.startBroadcast();
        InteractionContract interaction = new InteractionContract();
        vm.stopBroadcast();
        return interaction;
    }
    
}
