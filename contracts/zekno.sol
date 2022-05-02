// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "hardhat/console.sol";
import "./revealProof.sol";
import "./partialRevealProof.sol";
import "./mintProof.sol";

contract Zekno is ERC721 {
  struct CharacterAttributes {
    uint256 characterIndex;
    string name;
    string imageURI;        
    uint256 hp;
	uint256 stareDown;
	uint256 powerPunch;
	//uint256 karateChop;
  }


  // The tokenId is the NFTs unique identifier, it's just a number that goes
// 0, 1, 2, 3, etc.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // A lil array to help us hold the default data for our characters.
  // This will be helpful when we mint new characters and need to know
  // things like their HP, AD, etc.
  CharacterAttributes[] defaultCharacters;

  // We create a mapping from the nft's tokenId => that NFTs attributes.
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  struct BigBoss {
		string name;
		string imageURI;
		uint hp;
		uint256 stareDown;
		uint256 powerPunch;
		//uint256 karateChop;
	}

	BigBoss public bigBoss;

  // A mapping from an address => the NFTs tokenId. Gives me an ez way
  // to store the owner of the NFT and reference it later.
  mapping(address => uint256) public nftHolders;

	event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
	event AttackComplete(uint newBossHp, uint newPlayerHp, uint newBossStareDown, uint newBossPowerPunch, uint newPlayerStareDown, uint newPlayerPowerPunch); // /*uint newBossKarateChop,*/  // , uint newPlayerKarateChop

  // Data passed in to the contract when it's first created initializing the characters.
  // We're going to actually pass these values in from run.js.
  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
	uint256[] memory stareDown,
	uint256[] memory powerPunch,
//	uint256[] memory karateChop,
	string memory bossName, // These new variables would be passed in via run.js or deploy.js.
	string memory bossImageURI,
	uint256 bossHp,
	uint256 bossStareDown,
	uint256 bossPowerPunch
	//uint256 bossKarateChop
  )
      ERC721("Zekno", "ZEKNO")
  {
	// Initialize the boss. Save it to our global "bigBoss" state variable.
  	bigBoss = BigBoss({
		name: bossName,
		imageURI: bossImageURI,
		hp: bossHp,
		stareDown: bossStareDown,
		powerPunch: bossPowerPunch
		//karateChop: bossKarateChop
	});

 	console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);
    
	// Loop through all the characters, and save their values in our contract so
    // we can use them later when we mint our NFTs.
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
		stareDown: stareDown[i],
		powerPunch: powerPunch[i]
		//karateChop: karateChop[i]
      }));

    	CharacterAttributes memory c = defaultCharacters[i];
		// Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address

     	console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }

	// I increment _tokenIds here so that my first NFT has an ID of 1.
    _tokenIds.increment();
  }
  // to get J'SON for tokenURI
	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
	CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

	string memory strHp = Strings.toString(charAttributes.hp);
	string memory strStareDown = Strings.toString(charAttributes.stareDown);
	string memory strPowerPunch = Strings.toString(charAttributes.powerPunch);
	//string memory strKarateChop = Strings.toString(charAttributes.karateChop);

	string memory json = Base64.encode(
		abi.encodePacked(
		'{"name": "',
		charAttributes.name,
		' -- NFT #: ',
		Strings.toString(_tokenId),
		'", "description": "This is an NFT that lets people play in the game Zekno!", "image": "',
		charAttributes.imageURI,
		'", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,' }, { "trait_type": "Stare Down", "value": ',
		strStareDown,'}, { "trait_type": "Power Punch", "value": ',strPowerPunch,'} ] }'
		)
	);

	// , { "trait_type": "Karate Chop", "value": ',strKarateChop,'}

	string memory output = string(
		abi.encodePacked("data:application/json;base64,", json)
	);
	
	return output;
	}

	function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
		// Get the tokenId of the user's character NFT
		uint256 userNftTokenId = nftHolders[msg.sender];
		// If the user has a tokenId in the map, return their character.
		if (userNftTokenId > 0) {
			return nftHolderAttributes[userNftTokenId];
		}
		// Else, return an empty character.
		else {
			CharacterAttributes memory emptyStruct;
			return emptyStruct;
		}
	}
	function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
		return defaultCharacters;
	}

	function getBigBoss() public view returns (BigBoss memory) {
  		return bigBoss;
	}
/*
	function vrf() public view returns (bytes32 result) {
		uint[1] memory bn;
		bn[0] = block.number;
		assembly {
		let memPtr := mload(0x3)
		if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
			invalid()
		}
		result := mload(memPtr)
		}
    }
*/
	function attackBoss() public {
		// Get the state of the player's NFT.
		uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
		CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
		//bytes32 randomNumber = vrf();
		bytes32 randomNumber = '1';

		console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp);
		console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp);

		  // Make sure the player has more than 0 HP.
		require (
			player.hp > 0,
			"Error: character must have HP to attack boss."
		);

		// Make sure the boss has more than 0 HP.
		require (
			bigBoss.hp > 0,
			"Error: boss must have HP to attack boss."
		);

		if (randomNumber == '1'){
			// Allow player to attack boss.
			if (bigBoss.stareDown < player.stareDown) {
				bigBoss.stareDown = bigBoss.stareDown - 10;
				player.stareDown = player.stareDown + 10;
				bigBoss.hp--;
				player.hp++;
			} else if (bigBoss.stareDown > player.stareDown) {
				bigBoss.stareDown = bigBoss.stareDown + 10;
				player.stareDown = player.stareDown - 10;
				bigBoss.hp++;
				player.hp--;
			} else {
				//"This is a putt! Next round!";
				attackBoss();
			}
		} else if (randomNumber == '2') {
			// Allow player to attack boss.
			if (bigBoss.powerPunch < player.powerPunch) {
				bigBoss.powerPunch = bigBoss.powerPunch - 10;
				player.powerPunch = player.powerPunch + 10;
				bigBoss.hp--;
				player.hp++;
			} else if (bigBoss.powerPunch > player.powerPunch) {
				bigBoss.powerPunch = bigBoss.powerPunch + 10;
				player.powerPunch = player.powerPunch - 10;
				bigBoss.hp++;
				player.hp--;
			} else {
				//"This is a putt! Next round!";
				attackBoss();
			}
		} /*else if (randomNumber == '3') {	
			// Allow player to attack boss.
			if (bigBoss.karateChop < player.karateChop) {
				bigBoss.karateChop = bigBoss.karateChop - 10;
				player.karateChop = player.karateChop + 10;
				bigBoss.hp--;
				player.hp++;
			} else if (bigBoss.karateChop > player.karateChop) {
				bigBoss.karateChop = bigBoss.karateChop + 10;
				player.karateChop = player.karateChop - 10;
				bigBoss.hp++;
				player.hp--;
			} else {
				//"This is a putt! Next round!";
				attackBoss();
			}
		}*/

		// Console for ease.
		console.log("Attack complete. New boss hp: %s. New player hp: %s", bigBoss.hp, player.hp);

		emit AttackComplete(bigBoss.hp, player.hp, bigBoss.stareDown, bigBoss.powerPunch, /*bigBoss.karateChop,*/ player.stareDown, player.powerPunch); //, /*player.karateChop*/
	}	

  // Users would be able to hit this function and get their NFT based on the
  // characterId they send in!
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // We map the tokenId => their character attributes.
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      stareDown: defaultCharacters[_characterIndex].stareDown,
	  powerPunch: defaultCharacters[_characterIndex].powerPunch
	//  karateChop: defaultCharacters[_characterIndex].karateChop
	});

	// Increment the tokenId.
	_tokenIds.increment();

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
		

    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();

	emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }
}