const main = async () => {
	const gameContractFactory = await hre.ethers.getContractFactory('Zekno');
	
	const gameContract = await gameContractFactory.deploy(                        
		["Burrito", "Washy", "Jumpy"],       // Names
		["https://i.imgur.com/7pq0DqO.jpeg", // Images
		"https://i.imgur.com/9ogOIpq.jpeg", 
		"https://i.imgur.com/ix67cxp.jpeg"],
		[400, 300, 150],                    // HP values
		[100, 50, 25],
		"Evilene", // Boss name
		"https://i.imgur.com/0Lb8zLo.jpeg", // Boss image
		10000, // Boss hp
		50 // Boss attack damage                       // Attack damage values
	  );
  
	await gameContract.deployed();
	console.log("Contract deployed to:", gameContract.address);
  
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