// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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

interface IUniswapV2Factory {
    function getPair(address token0, address token1)
        external
        view
        returns (address);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}


contract dexPlatform {

    event Log(string message, uint256 value);

    address private constant FACTORY = 0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005;
    address private constant ROUTER = 0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c;
    address private constant WETH = 0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d;
    address private constant tt1 = 0xcD6a42782d230D7c13A74ddec5dD140e55499Df9;
    address private constant tt2 = 0xaE036c65C649172b43ef7156b009c6221B596B8b;

    IUniswapV2Router private router = IUniswapV2Router(ROUTER);
    IERC20 private weth = IERC20(WETH);
    IERC20 private TT1 = IERC20(tt1);

    // Swap WETH to TT1
    function swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = WETH;
        path[1] = tt1;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        
        return amounts[1];
    }

    
    function swapMultiHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        TT1.transferFrom(msg.sender, address(this), amountIn);
        TT1.approve(address(router), amountIn);

        address[] memory path;
        path = new address[](3);
        path[0] = tt1;
        path[1] = WETH;
        path[2] = tt2;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        
        return amounts[2];
    }

    
    function swapSingleHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        address[] memory path;
        path = new address[](2);
        path[0] = WETH;
        path[1] = tt1;

        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired, amountInMax, path, msg.sender, block.timestamp
        );

        // Refund WETH to msg.sender
        if (amounts[0] < amountInMax) {
            weth.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[1];
    }

    
    function swapMultiHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        TT1.transferFrom(msg.sender, address(this), amountInMax);
        TT1.approve(address(router), amountInMax);

        address[] memory path;
        path = new address[](3);
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



