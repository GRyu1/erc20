// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {MyToken} from "../src/MyToken.sol";
import {MyTokenScript} from "../script/MyToken.s.sol";

interface MintableToken {
    function mint(address, uint256) external;
}
contract MyTokenTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    MyToken public myToken;
    MyTokenScript public deployer;
    address public deployerAddress;
    address bob;
    address alice;

    function setUp() public {
        deployer = new MyTokenScript();
        myToken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        myToken.transfer(bob , BOB_STARTING_AMOUNT);
    }

    function test_InitialSupply() public view{
        assertEq(myToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function test_CanMintOnlyOwner() public {
        vm.expectRevert();
        MintableToken(address(myToken)).mint(address(this), 1);
    }

    function test_Allowances() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        myToken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);
        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }
}
