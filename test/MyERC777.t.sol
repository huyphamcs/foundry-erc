// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {MyERC777} from "../src/MyERC777.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import {IERC1820Registry} from "lib/openzeppelin-contracts/contracts/interfaces/IERC1820Registry.sol";
import {ERC1820RegistryMock} from "./mocks/ERC1820RegistryMock.sol";

contract MyERC777Test is Test{
    MyERC777 token;
    IERC1820Registry registry;
    address alice = address(0x1);
    address bob = address(0x2);
    // This 'operator' will manage all the things on behalf of the token owner
    // address operator = address(0x3);
    
    // address[] operators = [operator];

    address constant REGISTRY_ADDR = 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24;
    
    function setUp() public {
        if (REGISTRY_ADDR.code.length == 0){
            // Deploy mock registry and place it at the expected address
            ERC1820RegistryMock mockRegistry = new ERC1820RegistryMock();
            bytes memory code = address(mockRegistry).code;
            vm.etch(REGISTRY_ADDR, code);
        }
        registry = IERC1820Registry(REGISTRY_ADDR);
        token = new MyERC777();
        // token.mint(alice, 100 ether);
        // token.mint(bob, 200 ether);
    }

    function testMetadata()public{
        assertEq(token.name(), "Anderson Token");
        assertEq(token.symbol(), "ATK");
        // Check the smallest unit of the token
        assertEq(token.granularity(), 1);
        // Have not minted anything, so the total supply should be 0
        assertEq(token.totalSupply(), 0);
        // Let's mint
        token.mint(alice, 123);
        token.mint(bob, 456);
        assertEq(token.totalSupply(), 123 + 456);
    }

    function testMint() public {
        // console.log(uint(1));
        // uint256[] memory aliceBalance = getTokenBalances(token, alice);
        token.mint(alice, 100);
        token.mint(bob, 100);
        // Set the sender is 'alice'
        vm.prank(alice);
        token.send(bob, 40, "Alice sends 40 tokens");
        assertEq(token.balanceOf(alice), 60);
        assertEq(token.balanceOf(bob), 140);
        vm.prank(bob);
        token.send(alice, 20, "Bob sends 20 tokens");
        assertEq(token.balanceOf(alice), 80);
        assertEq(token.balanceOf(bob), 120);
        // After all the actions, the total supply should not change
        assertEq(token.totalSupply(), 200);
        // console.log(aliceBalance);
    }

    function testBurn() public {
        token.mint(alice, 100);
        token.mint(bob, 200);
        vm.prank(alice);
        token.burn(10, "Alice burns 10 tokens");
        assertEq(token.balanceOf(alice), 90);
        vm.prank(bob);
    }
    function testOperator() public {
        token.mint(alice, 100);
        token.mint(bob, 200);
        vm.prank(alice);
        // token.authorizeOperator(operator);
        address newOperator = address(0xcafe);
        token.authorizeOperator(newOperator);
        assertEq(token.isOperatorFor(address(0xcafe), alice), true);
        // vm.expectRevert();
        assertEq(token.isOperatorFor(address(0xcafeface), alice), false);
        vm.prank(newOperator);
        token.operatorSend(alice, bob, 10, "", "");
        assertEq(token.balanceOf(alice), 90);
        assertEq(token.balanceOf(bob), 210);
        
    }
}