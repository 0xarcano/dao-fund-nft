const deploy = async () => {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const nftName = "EthEcuadorAvatars";
  const nftSymbol = "EECA";
  const nftDescription = "Eth Ecuador Avatars";
  const nftMaxSupply = 100;
  const nftMintPrice = 35;
  const nftDaoTreasuryAddress = "0x88d2f5B400A7EF87bff74F66914019ec4FD1DD2d";
  const nftDaoTreasuryDonationPercentage = 10;
  const usdcContractAddress = "0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8";
  const usdtContractAddress = "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0";
  const daiContractAddress = "0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357";

  console.log("Deploying with parameters:");
  console.log("NFT Name:", nftName);
  console.log("NFT Symbol:", nftSymbol);
  console.log("NFT Description:", nftDescription);
  console.log("NFT Max Supply:", nftMaxSupply);
  console.log("NFT Mint Price:", nftMintPrice);
  console.log("NFT DAO Treasury Address:", nftDaoTreasuryAddress);
  console.log("NFT DAO Treasury Donation Percentage:", nftDaoTreasuryDonationPercentage);
  console.log("USDC Contract Address:", usdcContractAddress);
  console.log("USDT Contract Address:", usdtContractAddress);
  console.log("DAI Contract Address:", daiContractAddress);

  try {
    const DAOFundNFT = await ethers.getContractFactory("DAOFundNFT");
    const deployed = await DAOFundNFT.deploy(
      nftName,
      nftSymbol,
      nftDescription,
      nftMaxSupply,
      nftMintPrice,
      nftDaoTreasuryAddress,
      nftDaoTreasuryDonationPercentage,
      usdcContractAddress,
      usdtContractAddress,
      daiContractAddress
    );

    console.log("EthEcuadorAvatars deployed at:", deployed.address);
    await deployed.deployed(); // Wait for the contract to be fully deployed
    console.log("Contract deployment confirmed.");

  } catch (error) {
    console.error("Deployment failed:", error);
  }
};

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });