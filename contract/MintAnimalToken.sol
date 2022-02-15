// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MintAnimalToken is ERC721Enumerable { //애니멀 토큰 생성 
    constructor() ERC721("Yangtamin", "YTM"){}

    mapping (uint256 => uint256) public animalTypes;

    function mintAnimalToken() public {
        uint256 animalTokenId = totalSupply() + 1; //totalSupply는 지금까지 민팅된 nft양 (지금까지 32개가 민팅되었다면 다음 토큰 아이디는 31번이 됨)
        
        uint256 animalType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5 + 1;

        animalTypes[animalTokenId] = animalType;

        _mint(msg.sender, animalTokenId);
    }
}