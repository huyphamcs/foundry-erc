// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {MyERC721} from "../src/MyERC721.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";

contract BaseSetup is MyERC721, Test{
    MyERC721 public myNft;

    address payable[] internal _users;

    address internal _alice;
    address internal _bob;
    function setUp() public virtual {
        // Create 5 users with deterministic addresses
        for (uint256 i = 0; i < 5; i++) {
            address user = address(uint160(uint256(keccak256(abi.encodePacked("user", i)))));
            _users.push(payable(user));
        }

        _alice = _users[0];
        vm.label(_alice, "Alice");
        _bob = _users[1];
        vm.label(_bob, "Bob");
        myNft = new MyERC721();

        console.log("Alice address: ", _alice);
        console.log("Bob address: ", _bob);


    }
}

contract WhenMintNFT is BaseSetup{
    function setUp() public override{
        BaseSetup.setUp();
        // myNft.mintNft(_alice);
        // myNft.mintNft(_alice);

        
        
    }
    function testMintNFT() public {
        // Let's mint an nft
        myNft.mintNft(_alice);

        
        // console.log(myNft.balanceOf(_alice));
        assertEq(myNft.balanceOf(_alice),1);
        uint newTokenId = myNft.mintNft(_alice);
        // We mint another time, so the balance should be 2
        assertEq(myNft.balanceOf(_alice), 2);
        // And the current token id should be 2
        assertEq(newTokenId, 2);
        // console.log(myNft.balanceOf(_alice));
    }
    function testOwnerOfToken() public {
        myNft.mintNft(_alice);
        // Test if the owner is alice
        address owner = myNft.ownerOf(1);
        assertEq(owner , _alice);
    }   

    function testTransferFrom () public {
        // The sender is 'alice'
        // vm.prank(_alice);
        uint currentTokenId = myNft.mintNft(_alice); // This should be 1
        vm.prank(_alice);
        myNft.safeTransferFrom(_alice, _bob, currentTokenId);
        address newOwner = myNft.ownerOf(currentTokenId);
        // Check if the new owner is bob
        assertEq(newOwner, _bob);
        // Check if the new owner is not alice
        assert(newOwner != _alice);
        
    }

    function testGetBalance () public {
        uint loopTime = 2000;
        for(uint i = 0; i < loopTime; i++){
            myNft.mintNft(_alice);
        }
        uint currentBalance = myNft.balanceOf(_alice);
        assertEq(currentBalance, loopTime);
        // Try to send a random nft of alice to bob
        vm.prank(_alice);
        myNft.transferFrom(_alice, _bob, loopTime/2);
        assertEq(myNft.balanceOf(_alice), loopTime-1);
        assertEq(myNft.balanceOf(_bob), 1);
    }

    // function testOnlyOwnerBurn() public{
    //     uint currentTokenId = myNft.mintNft(_alice);
    //     vm.prank(_bob);
    //     vm.expectRevert(abi.encodePacked(""));
    //     myNft._burn(currentTokenId);
    // }
    function testApprove () public {
        myNft.mintNft(_alice);
        assertEq(myNft.ownerOf(1), _alice);
        vm.prank(_alice);
        myNft.approve(_bob, 1);
        address approved = myNft.getApproved(1);
        assertEq(approved, _bob);
    }
    function testSetApprovalForAll() public {
        myNft.mintNft(_alice);
        vm.prank(_alice);
        myNft.setApprovalForAll(_bob, true);
        bool approved = myNft.isApprovedForAll(_alice, _bob);
        assertEq(approved, true);
    }

    function testTrasferEvent()public {
        myNft.mintNft(_alice);
        vm.expectEmit(true, true, true, false);
        emit Transfer(_alice,_bob,1);
        vm.prank(_alice);
        myNft.safeTransferFrom(_alice, _bob, 1);
    }
}