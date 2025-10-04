const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying SpearEscrow to Sepolia...");
  
  const signers = await ethers.getSigners();
  const deployer = signers[0];
  
  if (!deployer) {
    throw new Error("No deployer account found. Check PRIVATE_KEY environment variable.");
  }
  
  console.log("Deploying with account:", deployer.address);
  
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH");
  
  if (balance === 0n) {
    throw new Error("Insufficient balance. Get ETH from Sepolia faucet.");
  }
  
  const SpearEscrow = await ethers.getContractFactory("SpearEscrow");
  console.log("Deploying contract...");
  
  const spearEscrow = await SpearEscrow.deploy();
  await spearEscrow.waitForDeployment();
  
  const contractAddress = await spearEscrow.getAddress();
  console.log("✅ SpearEscrow deployed to:", contractAddress);
  
  console.log("\nVerify with:");
  console.log(`npx hardhat verify --network sepolia ${contractAddress}`);
  
  console.log("\nUpdate frontend CONTRACT_ADDRESS to:", contractAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error.message);
    process.exit(1);
  });