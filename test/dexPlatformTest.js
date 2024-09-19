const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("dexPlatform", function () {
  let DexPlatform, dexPlatform, Token1, token1, Token2, token2, WETH, weth, owner, addr1;

  beforeEach(async () => {
    // Deploy mock tokens and the DexPlatform contract
    [owner, addr1] = await ethers.getSigners();

    // Mock Token1 and Token2
    Token1 = await ethers.getContractFactory("ERC20Mock");
    token1 = await Token1.deploy("Token1", "TT1", ethers.utils.parseEther("1000"));
    await token1.deployed();

    Token2 = await ethers.getContractFactory("ERC20Mock");
    token2 = await Token2.deploy("Token2", "TT2", ethers.utils.parseEther("1000"));
    await token2.deployed();

    WETH = await ethers.getContractFactory("ERC20Mock");
    weth = await WETH.deploy("Wrapped Ether", "WETH", ethers.utils.parseEther("1000"));
    await weth.deployed();

    DexPlatform = await ethers.getContractFactory("dexPlatform");
    dexPlatform = await DexPlatform.deploy();
    await dexPlatform.deployed();

    // Send tokens to addr1 for testing
    await token1.transfer(addr1.address, ethers.utils.parseEther("100"));
    await token2.transfer(addr1.address, ethers.utils.parseEther("100"));
    await weth.transfer(addr1.address, ethers.utils.parseEther("100"));
  });

  describe("Swap functionality", function () {
    it("should swap WETH to TT1 (Single Hop)", async function () {
      const amountIn = ethers.utils.parseEther("10");
      const amountOutMin = ethers.utils.parseEther("9");

      // Approve and swap
      await weth.connect(addr1).approve(dexPlatform.address, amountIn);
      await dexPlatform.connect(addr1).swapSingleHopExactAmountIn(amountIn, amountOutMin);

      const balanceTT1 = await token1.balanceOf(addr1.address);
      expect(balanceTT1).to.be.gt(ethers.utils.parseEther("9"));  // Assuming slippage tolerance
    });

    it("should perform multi-hop swap (TT1 -> WETH -> TT2)", async function () {
      const amountIn = ethers.utils.parseEther("10");
      const amountOutMin = ethers.utils.parseEther("8");

      await token1.connect(addr1).approve(dexPlatform.address, amountIn);
      await dexPlatform.connect(addr1).swapMultiHopExactAmountIn(amountIn, amountOutMin);

      const balanceTT2 = await token2.balanceOf(addr1.address);
      expect(balanceTT2).to.be.gt(ethers.utils.parseEther("8"));
    });
  });

  describe("Liquidity management", function () {
    it("should add liquidity for TT1 and TT2", async function () {
      const amountA = ethers.utils.parseEther("10");
      const amountB = ethers.utils.parseEther("10");

      await token1.connect(addr1).approve(dexPlatform.address, amountA);
      await token2.connect(addr1).approve(dexPlatform.address, amountB);

      const tx = await dexPlatform.connect(addr1).addLiquidity(token1.address, token2.address, amountA, amountB);
      await tx.wait();

      // Check emitted events for liquidity added
      await expect(tx).to.emit(dexPlatform, "Log").withArgs("Liquidity", anyValue);
    });

    it("should remove liquidity for TT1 and TT2", async function () {
      // Assuming liquidity was already added
      await dexPlatform.connect(addr1).removeLiquidity(token1.address, token2.address);

      const balanceTT1 = await token1.balanceOf(addr1.address);
      const balanceTT2 = await token2.balanceOf(addr1.address);
      
      expect(balanceTT1).to.be.gt(ethers.utils.parseEther("0"));
      expect(balanceTT2).to.be.gt(ethers.utils.parseEther("0"));
    });
  });
});
