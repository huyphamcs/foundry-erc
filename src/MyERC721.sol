// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Counters} from "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
// import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
contract MyERC721 is ERC721, Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Anderson NFT","AFT"){this;}
    function mintNft(address to) external onlyOwner() returns (uint) {
        _tokenIds.increment();
        uint newTokenId = _tokenIds.current();
        _mint(to, newTokenId);

        return newTokenId;
    }
}