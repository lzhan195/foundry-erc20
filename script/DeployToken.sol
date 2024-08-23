// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract DeployToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external {
        vm.startBroadcast();
        new TestToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
