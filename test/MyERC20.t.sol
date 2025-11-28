// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {MyERC20} from "../src/MyERC20.sol";
// import {Vm} from "lib/forge-std/src/Vm.sol";



contract BaseSetup is MyERC20, Test {
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
    }
}
contract WhenTransferingTokens is BaseSetup{
    uint internal _maxTransferAmount  = 12e18;
    function setUp() public virtual override{
        BaseSetup.setUp();
        console.log("When transfering tokens");
    }
    function transferToken (
        address from,
        address to,
        uint transferAmount
    ) public returns (bool) {
        // Set the caller to be the 'from' address
        vm.prank(from);
        // Use 'this.transfer()' to make it an external call so vm.prank() works
        return this.transfer(to, transferAmount);
    }
}
contract WhenAliceHasSufficientFunds is WhenTransferingTokens{
    uint internal _minAmount = _maxTransferAmount;
    function setUp() public override{
        WhenTransferingTokens.setUp();
        console.log("When Alice has sufficient funds");
        // Send '_alice' some fund
        _mint(_alice, _minAmount);
    }
    function itTransfersAmountCorrectly(
        address from,
        address to,
        uint amount
    ) public {

        uint fromBalance = balanceOf(from);
        bool success = transferToken(from, to, amount);
        assertTrue(success);
        // We hope that after the txn, the from balance = the from balance from the beginning - transfered amount
        assertEqDecimal(balanceOf(from), fromBalance - amount, decimals());
        // We hope that after the txn, the to balance = the to balance from the beginning (which is 0) + the transfered amount
        assertEqDecimal(balanceOf(to), amount, decimals());

    }
    function testTransferAllTokens() public {
        console.log("Test transfer all tokens");
        console.log(balanceOf(_alice));
        uint t  = _maxTransferAmount;
        console.log(t);
        itTransfersAmountCorrectly(_alice, _bob, t);
    }

    function testTrasnferHalfTokens() public {
        uint t = _maxTransferAmount/2;
        itTransfersAmountCorrectly(_alice, _bob, t);
    }

    function testTrasnferOneToken() public {
        itTransfersAmountCorrectly(_alice, _bob, 1);
    }

    
}


contract WhenAliceHasInsufficientFunds is WhenTransferingTokens{
    uint internal _minAmount = _maxTransferAmount - 1e18;

    function setUp() public override{
        WhenTransferingTokens.setUp();
        console.log("When Alice has insufficient funds");
        _mint(_alice, _minAmount);
    }

    function itRevertsTransfer(
        address from,
        address to, 
        uint amount,
        string memory expRevertMessage
    ) public {
        vm.expectRevert(abi.encodePacked(expRevertMessage));
        transferToken(from, to, amount);
    }

    function testCannotTransferMoreThanAvailable() public {
        itRevertsTransfer({from: _alice, to: _bob, amount: _maxTransferAmount,expRevertMessage: "ERC20: transfer amount exceeds balance"});
    }
    function testCannotTransferToZero() public {
        itRevertsTransfer({from: _alice, to:address(0), amount: _maxTransferAmount,expRevertMessage: "ERC20: transfer to the zero address"});
    }
}