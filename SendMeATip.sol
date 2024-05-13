//SPDX-License-Identifier: MIT
//

pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SendMeATip is Ownable {
    event NewTip(address indexed tipper, string name);

private address owner;

    struct Tip {
        address tipper;
        string name;
        uint256 value;
    }


    Tip[] Tips;


    constructor() Ownable(msg.sender) {
    }

    /**
     * @dev fetches all stored Tips
     */
    function getTips() public view returns (Tip[] memory) {
        return Tips;
    }

    /**
     * @dev give a tip to the owner in ETH
     * @param _name name of the tipper
     */
    function giveTip(string memory _name) public payable{
        require(msg.value > 0, "cannot buy coffee for free!");

        Tips.push(Tip(msg.sender, _name, msg.value));

        emit NewTip(msg.sender, _name);
    }

    /**
     * @dev send the entire balance stored in this contract to the owner
     */
    function withdrawTips() public {
        require(owner().send(address(this).balance));
    }


}
