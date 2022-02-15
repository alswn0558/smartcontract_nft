// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MintAnimalToken.sol";

contract SaleAnimalToken{
    MintAnimalToken public mintAnimalTokenAddress;

    constructor(address _mintAnimalTokenAddress){
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }

    mapping(uint256 => uint256) public animalTokenPrices;

    uint256[] public onSaleTokenArray;

    //판매함수
    function setForSaleAnimalToken(uint256 _animalTokenId, uint256 _price) public {
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(animalTokenOwner == msg.sender, "Caller is not animal token ower.");
        require(_price > 0, "Price is zero or lower.");
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale.");
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token.");

        animalTokenPrices[_animalTokenId] = _price;

        onSaleTokenArray.push(_animalTokenId);
    }
    
    //구매함수
    function purchaseAnimalToken (uint256 _animalTokenId) public payable { //payable이 붙어야 매틱이 왔다갔다하는 함수들을 실행할 수 있음
        uint256 price = animalTokenPrices[_animalTokenId];
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(price > 0, "Animal token not sale.");
        require(price <= msg.value, "Caller sent lower than price.");
        require(animalTokenOwner != msg.sender, "Caller is not animal token owner.");

        payable(animalTokenOwner).transfer(msg.value); //돈은 주인한테 보냄
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOwner, msg.sender, _animalTokenId); //물건은 주소의 소유자를 바꿔줌 (구입한사람이 소유함)

        animalTokenPrices[_animalTokenId] = 0; //이미 팔렸으니까 장터에서 지워버야됨 -> 가격을 0원으로 만들어버림

        for(uint256 i=0; i<onSaleTokenArray.length; i++){  // 가격이 0원인 애 (즉 장터에서 지워야하는 애)를 품목 배열에서 지워버림
            if(animalTokenPrices[onSaleTokenArray[i]] == 0){ //for문으로 검사하며 가격 0원이면 맨뒤랑 바꿔주고 .pop()
                onSaleTokenArray[i] = onSaleTokenArray[onSaleTokenArray.length -1];
                onSaleTokenArray.pop();
            }
        }
    }

    function getOnSaleAnimalToken() view public returns(uint256) {
        return onSaleTokenArray.length;
    }
}