const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DexPlatform", (m) => {
  
  const DexPlatform = m.contract("DexPlatform", [], {
  
  });

  return { DexPlatform };
});
