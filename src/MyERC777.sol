// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC777} from "lib/openzeppelin-contracts/contracts/token/ERC777/ERC777.sol";
contract MyERC777 is ERC777{
    constructor()
        ERC777("Anderson Token", "ATK", new address[](0))
    {this;}

    function mint(address account, uint256 amount) public {
        _mint(account, amount, "","");
    }
}