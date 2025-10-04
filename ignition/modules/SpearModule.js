const { buildModule } = require('@nomicfoundation/hardhat-ignition/modules');

module.exports = buildModule('SpearModule', (m) => {
  const spearEscrow = m.contract('SpearEscrow');

  return { spearEscrow };
});