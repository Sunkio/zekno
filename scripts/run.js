const main = async () => {
	const gameContractFactory = await hre.ethers.getContractFactory('Zekno');
	const gameContract = await gameContractFactory.deploy(
	  ["Burrito", "Washy", "Jumpy"],       // Names
	  ["https://i.imgur.com/7pq0DqO.jpeg", // Images
	  "https://i.imgur.com/9ogOIpq.jpeg", 
	  "https://i.imgur.com/ix67cxp.jpeg"],
	  [400, 300, 150],                    // HP values
	  [100, 50, 25],      // Attack damage values
	  "Evilene", // Boss name
	  "https://i.imgur.com/0Lb8zLo.jpeg", // Boss image
	  10000, // Boss hp
	  50 // Boss attack damage                  
	);
	
	await gameContract.deployed();
	console.log("Contract deployed to:", gameContract.address);

	let txn;
	// We only have three characters.
	// an NFT w/ the character at index 2 of our array.
	txn = await gameContract.mintCharacterNFT(2);
	await txn.wait();

	txn = await gameContract.attackBoss();
	await txn.wait();

	txn = await gameContract.attackBoss();
	await txn.wait();

	// Get the value of the NFT's URI.
	let returnedTokenUri = await gameContract.tokenURI(1);
	console.log("Token URI:", returnedTokenUri);
  };
  
  const runMain = async () => {
	try {
	  await main();
	  process.exit(0);
	} catch (error) {
	  console.log(error);
	  process.exit(1);
	}
  };
  
  runMain();
  