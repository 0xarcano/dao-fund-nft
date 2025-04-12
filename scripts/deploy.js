const deploy = async () => {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const CypherHumas = await ethers.getContractFactory("CypherHumas");
  const deployed = await CypherHumas.deploy();

  console.log("CypherHumas deployed at:", deployed.address);
};

deploy ()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })