// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title IUniswapV2Router Interface for Uniswap V2 Router
/// @notice Provides functions for token swapping, liquidity management, and more
interface IUniswapV2Router {
    /// @notice Swap an exact amount of input tokens for as many output tokens as possible
    /// @param amountIn The amount of input tokens to send
    /// @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert
    /// @param path An array of token addresses for the swap path (e.g., [tokenA, tokenB])
    /// @param to The address to receive the output tokens
    /// @param deadline The time by which the transaction must be completed
    /// @return amounts The input and output token amounts
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /// @notice Swap tokens to exactly receive a fixed amount of output tokens
    /// @param amountOut The exact amount of output tokens to receive
    /// @param amountInMax The maximum amount of input tokens that can be used
    /// @param path An array of token addresses for the swap path
    /// @param to The address to receive the output tokens
    /// @param deadline The time by which the transaction must be completed
    /// @return amounts The input and output token amounts
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /// @notice Add liquidity to a Uniswap V2 pair
    /// @param tokenA The address of the first token
    /// @param tokenB The address of the second token
    /// @param amountADesired The desired amount of tokenA to add as liquidity
    /// @param amountBDesired The desired amount of tokenB to add as liquidity
    /// @param amountAMin The minimum amount of tokenA that must be added
    /// @param amountBMin The minimum amount of tokenB that must be added
    /// @param to The address that will receive the liquidity tokens
    /// @param deadline The time by which the transaction must be completed
    /// @return amountA The actual amount of tokenA added
    /// @return amountB The actual amount of tokenB added
    /// @return liquidity The amount of liquidity tokens received
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    /// @notice Remove liquidity from a Uniswap V2 pair
    /// @param tokenA The address of the first token
    /// @param tokenB The address of the second token
    /// @param liquidity The amount of liquidity tokens to remove
    /// @param amountAMin The minimum amount of tokenA to receive
    /// @param amountBMin The minimum amount of tokenB to receive
    /// @param to The address to receive the tokens
    /// @param deadline The time by which the transaction must be completed
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}

/// @title IUniswapV2Factory Interface for Uniswap V2 Factory
/// @notice Provides functions to interact with Uniswap pairs
interface IUniswapV2Factory {
    /// @notice Get the address of the pair for two tokens
    /// @param token0 The address of the first token
    /// @param token1 The address of the second token
    /// @return The address of the pair
    function getPair(address token0, address token1)
        external
        view
        returns (address);
}

/// @title IWETH Interface for Wrapped Ether (WETH)
/// @notice Provides functions to interact with WETH, a tokenized version of Ether
interface IWETH is IERC20 {
    /// @notice Deposit Ether and receive WETH tokens
    function deposit() external payable;

    /// @notice Withdraw WETH and receive Ether
    /// @param amount The amount of WETH to withdraw
    function withdraw(uint256 amount) external;
}

/// @title A Decentralized Exchange Platform
/// @notice A smart contract for swapping tokens and managing liquidity on Uniswap V2
contract dexPlatform {

    /// @notice Log information related to transactions
    /// @param message A message describing the log event
    /// @param value The value associated with the event (e.g., token amount, liquidity amount)
    event Log(string message, uint256 value);

    address private constant FACTORY = 0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005;
    address private constant ROUTER = 0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c;
    address private constant WETH = 0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d;
    address private constant tt1 = 0xcD6a42782d230D7c13A74ddec5dD140e55499Df9;
    address private constant tt2 = 0xaE036c65C649172b43ef7156b009c6221B596B8b;

    IUniswapV2Router private router = IUniswapV2Router(ROUTER);
    IERC20 private weth = IERC20(WETH);
    IERC20 private TT1 = IERC20(tt1);

    /// @notice Swap WETH for TT1 tokens
    /// @param amountIn The amount of WETH to swap
    /// @param amountOutMin The minimum amount of TT1 tokens to receive
    /// @return amountOut The amount of TT1 tokens received
    function swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = tt1;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        return amounts[1];
    }

    /// @notice Swap TT1 for TT2 via WETH (Multi-hop swap)
    /// @param amountIn The amount of TT1 to swap
    /// @param amountOutMin The minimum amount of TT2 to receive
    /// @return amountOut The amount of TT2 tokens received
    function swapMultiHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        TT1.transferFrom(msg.sender, address(this), amountIn);
        TT1.approve(address(router), amountIn);

        address[] memory path = new address[](3);
        path[0] = tt1;
        path[1] = WETH;
        path[2] = tt2;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        return amounts[2];
    }

    /// @notice Swap WETH for a fixed amount of TT1 tokens
    /// @param amountOutDesired The exact amount of TT1 tokens to receive
    /// @param amountInMax The maximum amount of WETH to use for the swap
    /// @return amountOut The amount of TT1 tokens received
    function swapSingleHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = tt1;

        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired, amountInMax, path, msg.sender, block.timestamp
        );

        if (amounts[0] < amountInMax) {
            weth.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[1];
    }

    /// @notice Swap TT1 for a fixed amount of TT2 via WETH (Multi-hop swap)
    /// @param amountOutDesired The exact amount of TT2 tokens to receive
    /// @param amountInMax The maximum amount of TT1 to use for the swap
    /// @return amountOut The amount of TT2 tokens received
    function swapMultiHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        TT1.transferFrom(msg.sender, address(this), amountInMax);
        TT1.approve(address(router), amountInMax);

        address[] memory path = new address[](3);
        path[0] = tt1;
        path[1] = WETH;
        path[2] = tt2;

        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired, amountInMax, path, msg.sender, block.timestamp
        );

        if (amounts[0] < amountInMax) {
            TT1.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[2];
    }

    /// @notice Add liquidity to a Uniswap V2 pair
    /// @param _tokenA The address of the first token
    /// @param _tokenB The address of the second token
    /// @param _amountA The amount of tokenA to add
    /// @param _amountB The amount of tokenB to add
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    ) external payable {
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

        IERC20(_tokenA).approve(ROUTER, _amountA);
        IERC20(_tokenB).approve(ROUTER, _amountB);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = IUniswapV2Router(
            ROUTER
        ).addLiquidity(
            _tokenA,
            _tokenB,
            _amountA,
            _amountB,
            1,
            1,
            address(this),
            block.timestamp
        );

        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
        emit Log("Liquidity", liquidity);
    }

    /// @notice Remove liquidity from a Uniswap V2 pair
    /// @param _tokenA The address of the first token
    /// @param _tokenB The address of the second token
    function removeLiquidity(address _tokenA, address _tokenB) external payable{
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint256 liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);

        (uint256 amountA, uint256 amountB) = IUniswapV2Router(ROUTER)
            .removeLiquidity(
            _tokenA, _tokenB, liquidity, 1, 1, address(this), block.timestamp
        );

        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
    }
}
