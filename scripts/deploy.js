const deploy = async () => {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const testAccount = "0x8DE3D6653a1a04710E3C8170fEC3b030A2272D19";
  const initialSupply = ethers.utils.parseUnits("1000", 6); // 1000 tokens with 6 decimals

  try {
    // Deploy test ERC20 tokens
    console.log("Deploying test ERC20 tokens...");
    
    const TestERC20 = await ethers.getContractFactory("TestERC20");
    
    const usdc = await TestERC20.deploy("USD Coin", "USDC", 6);
    await usdc.deployed();
    await usdc.mint(testAccount, initialSupply);
    console.log("USDC deployed to:", usdc.address);
    
    const usdt = await TestERC20.deploy("Tether USD", "USDT", 6);
    await usdt.deployed();
    await usdt.mint(testAccount, initialSupply);
    console.log("USDT deployed to:", usdt.address);
    
    const dai = await TestERC20.deploy("Dai Stablecoin", "DAI", 18);
    await dai.deployed();
    await dai.mint(testAccount, ethers.utils.parseEther("1000")); // DAI uses 18 decimals
    console.log("DAI deployed to:", dai.address);

    // Deploy NFT contract
    const nftName = "EthEcuadorTest";
    const nftSymbol = "EECT";
    const nftDescription = "Eth Ecuador Avatars";
    const nftMaxSupply = 100;
    const nftMintPrice = 35;
    const nftDaoTreasuryAddress = "0x88d2f5B400A7EF87bff74F66914019ec4FD1DD2d";
    const nftDaoTreasuryDonationPercentage = 10;

    console.log("\nDeploying NFT with parameters:");
    console.log("NFT Name:", nftName);
    console.log("NFT Symbol:", nftSymbol);
    console.log("NFT Description:", nftDescription);
    console.log("NFT Max Supply:", nftMaxSupply);
    console.log("NFT Mint Price:", nftMintPrice);
    console.log("NFT DAO Treasury Address:", nftDaoTreasuryAddress);
    console.log("NFT DAO Treasury Donation Percentage:", nftDaoTreasuryDonationPercentage);
    console.log("USDC Contract Address:", usdc.address);
    console.log("USDT Contract Address:", usdt.address);
    console.log("DAI Contract Address:", dai.address);

    const DAOFundNFT = await ethers.getContractFactory("DAOFundNFT");
    const nft = await DAOFundNFT.deploy(
      nftName,
      nftSymbol,
      nftDescription,
      nftMaxSupply,
      nftMintPrice,
      nftDaoTreasuryAddress,
      nftDaoTreasuryDonationPercentage,
      usdc.address,
      usdt.address,
      dai.address
    );

    await nft.deployed();
    console.log("\nEthEcuadorAvatars deployed at:", nft.address);
    console.log("Contract deployment confirmed.");

  } catch (error) {
    console.error("Deployment failed:", error);
    throw error;
  }
};

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });