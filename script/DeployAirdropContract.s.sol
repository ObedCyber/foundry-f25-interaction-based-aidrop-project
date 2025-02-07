// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {AirdropContract} from "../src/AirdropContract.sol";
import {AirdropToken} from "../src/AirdropToken.sol";
import {InteractionContract} from "../src/InteractionContract.sol";
import {console} from "forge-std/console.sol";

contract DeployAirdropContract is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;
    uint256 public DEFAULT_ANVIL_KEY = vm.envUint("PRIVATE_KEY"); 
    address public localAddress = vm.envAddress("LOCAL_ADDRESS");
    uint256 public interactionThreshold = 3;
    uint256 public startTime = block.timestamp;
    uint256 public endTime = startTime + (72 * 60 * 60);

    function run() external returns(AirdropToken, address, InteractionContract, AirdropContract, uint256, uint256, uint256)
    {
        vm.startBroadcast(DEFAULT_ANVIL_KEY);
        AirdropToken airdorpToken = new AirdropToken(INITIAL_SUPPLY);
        InteractionContract interaction = new InteractionContract();
        AirdropContract airdropContract = new AirdropContract(address(airdorpToken), address(interaction), interactionThreshold, startTime, endTime);
        console.log("AirdropToken deployed to:", address(airdorpToken));
        console.log("InteractionContract deployed to:", address(interaction));

        vm.stopBroadcast();
        return (airdorpToken, localAddress, interaction, airdropContract, interactionThreshold, startTime, endTime);
    }
}