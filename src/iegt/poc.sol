pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./TokenIGET.sol";

contract ContractTest is Test { 

    function setUp() public {
        uint256 forkId = vm.createFork("bsc", 30188943);
        vm.selectFork(forkId);
    }

    function testExp() public {
        TokenIEGT token = new TokenIEGT();

        console.log("Attacker balance: %s", token.balanceOf(0x00002b9b0748d575CB21De3caE868Ed19a7B5B56));
    }
}