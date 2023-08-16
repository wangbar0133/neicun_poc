// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV3Pool{
    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

interface IVault {
    function deposit(uint256 assets, address receiver) external payable returns (uint256 shares);

    function mint(uint256 amount, address account) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function totalAssets() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function withdraw(uint256 _amount, address _receiver) external returns (uint256, uint256);

    function convertToAssets(uint256 shares) external returns(uint256);
}

interface IWETH {
    function transfer(address to, uint256 amount) external returns (bool);

    function withdraw(uint wad) external;

    function deposit() payable external;

    function balanceOf(address account) external view returns (uint256);

    receive() external payable;
    
    fallback() external payable;
}
