// contracts/STT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract STT is ERC20 {
    uint256 maxSupply;
    uint lastMintTime;
    uint stage;
    uint256 [] division;
    address owner;

    constructor() ERC20("Start Token", "STT") {
        maxSupply = 1000000000 * 10 ** 18;
        owner = msg.sender;
        lastMintTime = block.timestamp;
        stage = 0;
        division = [400, 225, 175, 125, 75];
        _mint(owner, maxSupply * division[stage] / 1000);
        stage++;
    }

    function mintNextCycle() public {
        require(msg.sender == owner, "not owner");
        require(maxSupply > totalSupply(), "all supplies minted");
        require(block.timestamp - lastMintTime > 365 days, "not reach next stage");
        lastMintTime += 365 days;
        _mint(owner, maxSupply * division[stage] / 1000);
        stage++;
    }
}
