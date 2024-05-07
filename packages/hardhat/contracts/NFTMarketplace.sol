// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFTMarketplace is Ownable {
    using Counters for Counters.Counter;
    using Address for address payable;

    struct NFT {
        address owner;
        uint price;
    }

    mapping(uint => NFT) public nfts;
    mapping(address => Counters.Counter) private userNftCount;

    event NFTListed(uint indexed tokenId, address indexed owner, uint price);
    event NFTSold(uint indexed tokenId, address indexed buyer, uint price);

    function listNFT(uint tokenId, uint price) external {
        require(nfts[tokenId].owner == address(0), "NFT is already listed");
        nfts[tokenId] = NFT(msg.sender, price);
        userNftCount[msg.sender].increment();
        emit NFTListed(tokenId, msg.sender, price);
    }

    function buyNFT(uint tokenId) external payable {
        require(nfts[tokenId].owner != address(0), "NFT is not listed");
        require(msg.value >= nfts[tokenId].price, "Insufficient funds");

        address payable seller = payable(nfts[tokenId].owner);
        seller.transfer(msg.value);

        _transferNFT(tokenId, msg.sender);
        emit NFTSold(tokenId, msg.sender, nfts[tokenId].price);
    }

    function _transferNFT(uint tokenId, address buyer) private {
        nfts[tokenId].owner = buyer;
        userNftCount[msg.sender].decrement();
        userNftCount[buyer].increment();
    }

    function getUserNFTCount(address user) external view returns (uint) {
        return userNftCount[user].current();
    }
}