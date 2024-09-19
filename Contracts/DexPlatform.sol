// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Imports the ERC20 token interface from the OpenZeppelin library, which allows interaction with ERC20 tokens.
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


contract dexPlatform {

    // Event declaration for logging messages and values.
    event Log(string message, uint256 value);

    // Deployed addresses for the Uniswap factory, router, WETH, and custom tokens (TT1 and TT2).
    address private constant FACTORY = 0x330158E42De9e04d12f42711d00eF3C4ed03D27a;
    address private constant ROUTER = 0x84882A460D3F7bd1a2fa98ed1470D2870C914398;
    address private constant WETH = 0x4cA4ca0ebC0b16E4D44C0C66C6b3f8411af7446a;
    address private constant TT1 = 0x01FBe68E011E86891DE01eE8c7350Ffb8465D769;
    address private constant TT2 = 0xa0F9970aB4c2C8234962eA3F97522fa1cdd590EC;

    // Creating instances of the router and token contracts to interact with them.
    IUniswapV2Router private router = IUniswapV2Router(ROUTER);
    IERC20 private weth = IERC20(WETH);
    IERC20 private tt1 = IERC20(TT1);
    IERC20 private tt2 = IERC20(TT2);

    // Function to swap TT1 to TT2 using a single-hop swap.
    // amountIn: Amount of TT1 the user wants to swap.
    // amountOutMin: Minimum amount of TT2 that the user expects to receive.
    function swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        // Transfers TT1 tokens from the user to the contract.
        tt1.transferFrom(msg.sender, address(this), amountIn);
        
        // Approves the router to spend TT1 tokens.
        tt1.approve(address(router), amountIn);

        // Defines the swap path: from TT1 to TT2 (single-hop).
        address[] memory path;
        path = new address[](2);
        path[0] = TT1;
        path[1] = TT2;

        // Executes the token swap on the router.
        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        // Returns the amount of TT2 received.
        return amounts[1];
    }

    // Function to swap TT1 to TT2 through WETH (multi-hop swap).
    // amountIn: Amount of TT1 the user wants to swap.
    // amountOutMin: Minimum amount of TT2 expected from the swap.
    function swapMultiHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        // Transfers TT1 tokens from the user to the contract.
        tt1.transferFrom(msg.sender, address(this), amountIn);
        
        // Approves the router to spend TT1 tokens.
        tt1.approve(address(router), amountIn);

        // Defines the swap path: from TT1 to WETH to TT2 (multi-hop).
        address[] memory path;
        path = new address[](3) ;
        path[0] = TT1;
        path[1] = WETH;
        path[2] = TT2;

        // Executes the multi-hop token swap on the router.
        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        // Returns the amount of TT2 received.
        return amounts[2];
    }

    // Function to swap WETH to TT1 with a target output amount.
    // amountOutDesired: Exact amount of TT1 the user wants.
    // amountInMax: Maximum amount of WETH the user is willing to spend.
    function swapSingleHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        // Transfers WETH tokens from the user to the contract.
        weth.transferFrom(msg.sender, address(this), amountInMax);
        
        // Approves the router to spend WETH tokens.
        weth.approve(address(router), amountInMax);

        // Defines the swap path: from WETH to TT1.
        address[] memory path;
        path = new address[](2) ;
        path[0] = WETH;
        path[1] = TT1;

        // Executes the swap with a target output (amountOutDesired).
        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired, amountInMax, path, msg.sender, block.timestamp
        );

        // Refunds any leftover WETH to the user if less than the maximum was used.
        if (amounts[0] < amountInMax) {
            weth.transfer(msg.sender, amountInMax - amounts[0]);
        }

        // Returns the amount of TT1 received.
        return amounts[1];
    }

    // Function to swap TT1 to TT2 (via WETH) with a target output amount (multi-hop).
    // amountOutDesired: Exact amount of TT2 the user wants.
    // amountInMax: Maximum amount of TT1 the user is willing to spend.
    function swapMultiHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        // Transfers TT1 tokens from the user to the contract.
        tt1.transferFrom(msg.sender, address(this), amountInMax);
        
        // Approves the router to spend TT1 tokens.
        tt1.approve(address(router), amountInMax);

        // Defines the swap path: from TT1 to WETH to TT2.
        address[] memory path;
        path = new address[](3) ;
        path[0] = TT1;
        path[1] = WETH;
        path[2] = TT2;

        // Executes the swap with a target output (amountOutDesired).
        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired, amountInMax, path, msg.sender, block.timestamp
        );

        // Refunds any leftover TT1 to the user if less than the maximum was used.
        if (amounts[0] < amountInMax) {
            tt1.transfer(msg.sender, amountInMax - amounts[0]);
        }

        // Returns the amount of TT2 received.
        return amounts[2];
    }

    // Function to add liquidity to a pool of two tokens.
    // _tokenA: Address of the first token.
    // _tokenB: Address of the second token.
    // _amountA: Amount of the first token to be added as liquidity.
    // _amountB: Amount of the second token to be added as liquidity.
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    ) external payable {
        // Transfers tokens from the user to the contract.
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

        // Approves the router to spend the transferred tokens.
        IERC20(_tokenA).approve(ROUTER, _amountA);
        IERC20(_tokenB).approve(ROUTER, _amountB);

        // Adds liquidity to the Uniswap pool.
        (uint256 amountA, uint256 amountB, uint256 liquidity) = IUniswapV2Router(
            ROUTER
        ).addLiquidity(
            _tokenA,
            _tokenB,
            _amountA,
            _amountB,
            1,  // Minimum amount of tokenA.
            1,  // Minimum amount of tokenB.
            address(this),  // Liquidity is added for this contract.
            block.timestamp
        );

        // Logs the amounts added and the liquidity created.
        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
        emit Log("Liquidity", liquidity);
    }

    // Function to remove liquidity from a pool of two tokens.
    // _tokenA: Address of the first token.
    // _tokenB: Address of the second token.
    function removeLiquidity(address _tokenA, address _tokenB) external payable {
        // Retrieves the pair address for the token pool from the factory.
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        // Retrieves the liquidity balance of the contract for the pool.
        uint256 liquidity = IERC20(pair).balanceOf(address(this));
        
        // Approves the router to spend the liquidity tokens.
        IERC20(pair).approve(ROUTER, liquidity);

        // Removes liquidity from the pool and retrieves the token amounts.
        (uint256 amountA, uint256 amountB) = IUniswapV2Router(ROUTER)
            .removeLiquidity(
            _tokenA, _tokenB, liquidity, 1, 1, address(this), block.timestamp
        );

        // Logs the amounts of tokens received after removing liquidity.
        emit Log("amountA", amountA);
        emit Log("amountB", amountB);
    }
}

// Interface for interacting with Uniswap V2 Router.
interface IUniswapV2Router {
    // Swaps an exact amount of tokens for as many output tokens as possible.
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    // Swaps tokens for an exact amount of output tokens.
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    // Adds liquidity to a pool of two tokens.
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

    // Removes liquidity from a pool of two tokens.
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

// Interface for interacting with Uniswap V2 Factory.
interface IUniswapV2Factory {
    // Retrieves the pair address for a token pair.
    function getPair(address token0, address token1)
        external
        view
        returns (address);
}

// WETH (wrapped ETH) interface that includes deposit and withdrawal functionality.
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}
