const main = async () => {
	const gameContractFactory = await hre.ethers.getContractFactory('Zekno');
	
	const gameContract = await gameContractFactory.deploy(                        
		["Burrito", "Washy", "Jumpy"],       // Names
		["https://i.imgur.com/7pq0DqO.jpeg", // Images
		"https://i.imgur.com/9ogOIpq.jpeg", 
		"https://i.imgur.com/ix67cxp.jpeg"],
		[400, 300, 150],                    // HP values
		[1000, 500, 250],       // Stare Down values
		[100, 450, 725],   // PowerPunch values
		//[50, 1000, 625],     // KarateChop values  
		"Evilene", // Boss name
		"https://i.imgur.com/0Lb8zLo.jpeg", // Boss image
		10000, // Boss hp
		1000, // Boss Stare Down    
		350, // Boss PowerPunch
		//500
		 // Boss KarateChop
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