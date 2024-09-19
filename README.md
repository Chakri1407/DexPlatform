
# DexPlatform 

## Overview

The `dexPlatform` smart contract is designed to interact with a decentralized exchange (DEX) platform like Uniswap. It allows users to:
- Swap tokens (WETH, TT1, and TT2) with both single-hop and multi-hop swaps.
- Add and remove liquidity to/from a liquidity pool.

The contract is built using Solidity and leverages Uniswap's router and factory interfaces for liquidity management and token swaps.

## Contract Details

### Addresses
- **FACTORY**:[0x330158E42De9e04d12f42711d00eF3C4ed03D27a](https://amoy.polygonscan.com/address/0x330158E42De9e04d12f42711d00eF3C4ed03D27a) 
The address of the Uniswap factory used to get the pair address for liquidity pools.
- **ROUTER**:[0x84882A460D3F7bd1a2fa98ed1470D2870C914398](https://amoy.polygonscan.com/address/0x84882A460D3F7bd1a2fa98ed1470D2870C914398) 
The address of the Uniswap router used for swaps and liquidity management.
- **WETH**:[0x4cA4ca0ebC0b16E4D44C0C66C6b3f8411af7446a](https://amoy.polygonscan.com/address/0x4cA4ca0ebC0b16E4D44C0C66C6b3f8411af7446a) 
The address of the Wrapped Ether (WETH) token.
- **TT1**:[0x01FBe68E011E86891DE01eE8c7350Ffb8465D769](https://amoy.polygonscan.com/address/0x01FBe68E011E86891DE01eE8c7350Ffb8465D769) 
The address of Test Token 1 (TT1).
- **TT2**:[0xa0F9970aB4c2C8234962eA3F97522fa1cdd590EC](https://amoy.polygonscan.com/address/0xa0F9970aB4c2C8234962eA3F97522fa1cdd590EC) 
The address of Test Token 2 (TT2).
- **Dex**:- [0x56b875BD3e2D4E145FFa2905fDfed69E8E7EcAaA](https://amoy.polygonscan.com/address/0x56b875BD3e2D4E145FFa2905fDfed69E8E7EcAaA) 
The adress of the DexPlatform.

### Key Functions
1. **swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)**
   - Swaps WETH to TT1 using a single-hop swap.
   - Transfers `amountIn` of WETH from the sender to the contract and performs the swap using the Uniswap router.
   - Returns the amount of TT1 received after the swap.

2. **swapMultiHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)**
   - Swaps TT1 → WETH → TT2 using a multi-hop swap.
   - Transfers `amountIn` of TT1 from the sender and performs the swap, returning the amount of TT2.

3. **swapSingleHopExactAmountOut(uint256 amountOutDesired, uint256 amountInMax)**
   - Swaps WETH to TT1 targeting an exact amount of TT1 (`amountOutDesired`), with an upper limit on the input (`amountInMax`).
   - Refunds any excess WETH if the swap uses less than `amountInMax`.

4. **swapMultiHopExactAmountOut(uint256 amountOutDesired, uint256 amountInMax)**
   - Swaps TT1 → WETH → TT2 targeting an exact amount of TT2 (`amountOutDesired`), with an upper limit on the input (`amountInMax`).
   - Refunds any excess TT1 if the swap uses less than `amountInMax`.

5. **addLiquidity(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB)**
   - Adds liquidity to the Uniswap pool for `_tokenA` and `_tokenB`.
   - Transfers `_amountA` of `_tokenA` and `_amountB` of `_tokenB` from the sender, approves the router, and adds liquidity.

6. **removeLiquidity(address _tokenA, address _tokenB)**
   - Removes liquidity from the Uniswap pool for `_tokenA` and `_tokenB`.
   - Approves and removes liquidity, transferring the pool's tokens back to the contract.

## Prerequisites

Before you interact with this contract, ensure the following:
1. **Node.js and npm**: Install Node.js.
2. **Hardhat**: Hardhat is a development environment for Ethereum. Install it globally:
   ```bash
   npm install --save-dev hardhat


### Installation
1. Clone the repository:

``` git clone <repository_url> ```
``` cd <repository_directory> ```

2. Install dependencies:

``` npm install ``` 

3. Compile the smart contract:

``` npx hardhat compile ``` 

4. Run tests

``` npx hardhat test ``` 


## Running Tests
We provide sample unit tests written using Hardhat's test framework. These tests cover:

Token swapping (single-hop and multi-hop).
Adding and removing liquidity.

## Contract Deployment
To deploy the contract, you can use the Hardhat deployment script. Make sure to configure the appropriate network settings in your ``` hardhat.config.js```  file. 

## License
This project is licensed under the MIT License.

## Authors

- [@ChakravarthyN](https://github.com/Chakri1407)


## FAQ

#### Question 
For any questions, please feel free to reach out to me at: [![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/chakravarthy-naik-9626bb1ba/)
