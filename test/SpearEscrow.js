const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('SpearEscrow', function () {
  let spearEscrow;
  let owner, client, developer;

  beforeEach(async function () {
    [owner, client, developer] = await ethers.getSigners();
    
    const SpearEscrow = await ethers.getContractFactory('SpearEscrow');
    spearEscrow = await SpearEscrow.deploy();
    await spearEscrow.waitForDeployment();
  });

  describe('Project Creation', function () {
    it('Should create a project with milestones', async function () {
      const milestones = [ethers.parseEther('0.5'), ethers.parseEther('0.5')];
      const riskFund = ethers.parseEther('0.1');
      const totalAmount = ethers.parseEther('1.1');
      
      const tx = await spearEscrow.connect(client).createProject(
        'Test project',
        milestones,
        riskFund,
        0, // Basic protection
        { value: totalAmount }
      );
      
      const receipt = await tx.wait();
      expect(receipt.status).to.equal(1);
    });

    it('Should enforce minimum amount', async function () {
      const milestones = [ethers.parseEther('0.001')];
      
      try {
        await spearEscrow.connect(client).createProject(
          'Small project',
          milestones,
          0,
          0,
          { value: ethers.parseEther('0.001') }
        );
        expect.fail('Should have reverted');
      } catch (error) {
        expect(error.message).to.include('Minimum 10 USDT');
      }
    });
  });

  describe('Developer Application', function () {
    let projectId;

    beforeEach(async function () {
      const milestones = [ethers.parseEther('0.5')];
      const totalAmount = ethers.parseEther('0.5');
      
      await spearEscrow.connect(client).createProject(
        'Test project',
        milestones,
        0,
        0,
        { value: totalAmount }
      );
      projectId = 1;
    });

    it('Should allow developer to apply', async function () {
      const tx = await spearEscrow.connect(developer).applyToProject(projectId);
      const receipt = await tx.wait();
      expect(receipt.status).to.equal(1);
    });

    it('Should allow client to approve developer', async function () {
      await spearEscrow.connect(developer).applyToProject(projectId);
      
      const tx = await spearEscrow.connect(client).approveDeveloper(projectId, developer.address);
      const receipt = await tx.wait();
      expect(receipt.status).to.equal(1);
    });
  });
});