require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks:{
    polygonAmoy:{
     url:process.env.PROVIDER_URL,
     accounts:[process.env.PRIVATE_KEY] 
    }
  }
};
