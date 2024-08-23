// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {TestToken} from "../src/TestToken.sol";
import {DeployToken} from "../script/DeployToken.sol";

contract TestTokenTest is Test {
    TestToken public tt;
    DeployToken public deployer;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address carol = makeAddr("carol");
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function setUp() public {
        deployer = new DeployToken();
        tt = deployer.run();
        vm.prank(msg.sender);
        tt.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public view {
        assertEq(tt.totalSupply(), INITIAL_SUPPLY);
    }

    function testBobBalance() public view {
        assertEq(tt.balanceOf(bob), STARTING_BALANCE);
    }

    function testTransfer() public {
        uint256 transferAmount = 50 ether;
        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, transferAmount);

        bool success = tt.transfer(alice, transferAmount);
        assertTrue(success);
        assertEq(tt.balanceOf(alice), transferAmount);
        assertEq(tt.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testFailTransferInsufficientBalance() public {
        vm.prank(bob);
        tt.transfer(alice, STARTING_BALANCE + 1 ether);
    }

    function testApprove() public {
        uint256 approvalAmount = 1000;
        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, approvalAmount);

        bool success = tt.approve(alice, approvalAmount);
        assertTrue(success);
        assertEq(tt.allowance(bob, alice), approvalAmount);
    }

    function testAllowance() public {
        uint256 approvalAmount = 1000;
        vm.prank(bob);
        tt.approve(alice, approvalAmount);
        assertEq(tt.allowance(bob, alice), approvalAmount);
    }

    function testTransferFrom() public {
        uint256 approvalAmount = 1000;
        uint256 transferAmount = 500;
        vm.prank(bob);
        tt.approve(alice, approvalAmount);

        vm.prank(alice);

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, carol, transferAmount);

        bool success = tt.transferFrom(bob, carol, transferAmount);
        assertTrue(success);
        assertEq(tt.balanceOf(carol), transferAmount);
        assertEq(tt.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(tt.allowance(bob, alice), approvalAmount - transferAmount);
    }

    function testFailTransferFromInsufficientAllowance() public {
        uint256 approvalAmount = 1000;
        uint256 transferAmount = 1001;
        vm.prank(bob);
        tt.approve(alice, approvalAmount);

        vm.prank(alice);
        tt.transferFrom(bob, carol, transferAmount);
    }

    function testName() public view {
        assertEq(tt.name(), "TestToken");
    }

    function testSymbol() public view {
        assertEq(tt.symbol(), "TT");
    }

    function testDecimals() public view {
        assertEq(tt.decimals(), 18);
    }

    function testTransferZeroAmount() public {
        uint256 initialBalanceBob = tt.balanceOf(bob);
        uint256 initialBalanceAlice = tt.balanceOf(alice);

        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, 0);

        bool success = tt.transfer(alice, 0);

        assertTrue(success);
        assertEq(tt.balanceOf(bob), initialBalanceBob);
        assertEq(tt.balanceOf(alice), initialBalanceAlice);
    }

    function testApproveZeroAmount() public {
        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, 0);

        bool success = tt.approve(alice, 0);

        assertTrue(success);
        assertEq(tt.allowance(bob, alice), 0);
    }

    function testTransferFromZeroAmount() public {
        vm.prank(bob);
        tt.approve(alice, 1000);

        vm.prank(alice);

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, carol, 0);

        bool success = tt.transferFrom(bob, carol, 0);

        assertTrue(success);
        assertEq(tt.allowance(bob, alice), 1000);
        assertEq(tt.balanceOf(bob), STARTING_BALANCE);
        assertEq(tt.balanceOf(carol), 0);
    }

    function testApprovalEvent() public {
        uint256 approvalAmount = 1000;
        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, approvalAmount);

        tt.approve(alice, approvalAmount);
    }

    function testTransferEvent() public {
        uint256 transferAmount = 50 ether;
        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, transferAmount);

        tt.transfer(alice, transferAmount);
    }

    function testTransferFromEvent() public {
        uint256 approvalAmount = 1000;
        uint256 transferAmount = 500;
        vm.prank(bob);
        tt.approve(alice, approvalAmount);

        vm.prank(alice);

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, carol, transferAmount);

        tt.transferFrom(bob, carol, transferAmount);
    }
}
