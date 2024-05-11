// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GreenID.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestGreenID is Test {
    address constant CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;

    address private proxy;
    GreenID private instance;

    function setUp() public {
        proxy = Upgrades.deployUUPSProxy(
            "GreenID.sol",
            abi.encodeCall(GreenID.initialize, (CHEATCODE_ADDRESS))
        );

        console.log("uups proxy -> %s", proxy);
        
        instance = GreenID(proxy);
        assertEq(instance.owner(), CHEATCODE_ADDRESS);

        address implAddressV1 = Upgrades.getImplementationAddress(proxy);

        console.log("impl proxy -> %s", implAddressV1);
    }
    
    function testMint() public {
        vm.prank(CHEATCODE_ADDRESS);

        instance.mint(CHEATCODE_ADDRESS, 1);
        assertEq(instance.ownerOf(1), CHEATCODE_ADDRESS);

        vm.prank(CHEATCODE_ADDRESS);

        instance.claim(1);
        assertTrue(instance.claimedTokens(1));
    }

}