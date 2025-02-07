// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {AirdropToken} from "../src/AirdropToken.sol";
import {console} from "forge-std/console.sol";

contract DeployAirdropToken is Script {
    
    uint256 public constant INITIAL_SUPPLY = 1000 ether;
    uint256 public DEFAULT_ANVIL_KEY = vm.envUint("PRIVATE_KEY"); 
    address public localAddress = vm.envAddress("LOCAL_ADDRESS"); 

    function run() external returns (AirdropToken, address) {

        vm.startBroadcast(DEFAULT_ANVIL_KEY);
        AirdropToken airdorpToken = new AirdropToken(INITIAL_SUPPLY);
        console.log("AirdropToken deployed to:", address(airdorpToken));
        vm.stopBroadcast();
        return (airdorpToken, localAddress);

    }
}