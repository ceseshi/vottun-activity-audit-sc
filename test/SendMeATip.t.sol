// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/SendMeATip.sol";

contract SendMeATipTest is Test {
    SendMeATip sendMeATip;

    // Prepare addresses
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");

    function setUp() public {

        vm.prank(alice);
        sendMeATip = new SendMeATip();

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function testTip() public {
        uint256 tip = 0.01 ether;

        vm.prank(bob);
        sendMeATip.giveTip{value: tip}("bob");

        SendMeATip.Tip[] memory tips = sendMeATip.getTips();
        assertEq(tips[0].tipper, bob);
        assertEq(tips[0].value, tip);

        vm.prank(alice);
        sendMeATip.withdrawTips();

        assertEq(bob.balance, 1 ether - tip);
        assertEq(alice.balance, 1 ether + tip);
    }
}