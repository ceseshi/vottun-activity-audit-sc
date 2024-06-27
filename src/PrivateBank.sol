pragma solidity 0.8.20;

// SPDX-License-Identifier: MIT

contract PrivateBank {
    mapping(address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = getUserBalance(msg.sender);

        require(balance > 0, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
}
