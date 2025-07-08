// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// Import Hardhat's console.sol for debugging (can be removed in production)
import "hardhat/console.sol";

contract AVAXGods {
    // Define a constant payable address
    address payable public constant fixedAddress = payable(0x01Cf63485A236263491412A0a5010CF2FEC44154);

    // Event to log the details of the swap
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Function to swap Ether to the fixed address
    function transfer() external payable {
        // Ensure the sent amount is greater than 0
        require(msg.value > 0, "Amount must be greater than 0");

        // Transfer the sent Ether to the fixed address
        fixedAddress.transfer(msg.value);

        // Emit the Swap event
        emit Transfer(msg.sender, fixedAddress, msg.value);
    }
}