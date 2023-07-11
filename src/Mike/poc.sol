pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./Mike.sol";

contract ContractTest is Test {

    address public victim = 0xeF7aA5930b2E92e7EF59BACfE18A0A3cb2105747;
    address public backDoor = 0xF7E0d99511eab452bCBBdC34285E25F10E28F79D;
    Mike public mike = Mike(0x8B99Bb8ddD8103CbEccC3b20C4B0038cA65A51AE);

    function setUp() public {
        uint256 forkId = vm.createFork("mainnet", 17608449);
        vm.selectFork(forkId);
    }

    function testFail_Approve() public {
        vm.prank(backDoor);
        mike.Approve(victim, 1);

        vm.prank(victim);
        mike.transfer(address(0), 1);
    }

    function testFreeMint() public {
        vm.prank(backDoor);
        mike.increaseAllowance(backDoor, 1262000000000000000000000000000000);
        assertEq(mike.balanceOf(backDoor), 1262000000000000000000000000000000);
    }
}

