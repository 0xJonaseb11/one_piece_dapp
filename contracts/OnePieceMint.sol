// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { VRFCoordinatorV2Interface } from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import { VRFConsumerBaseV2 } from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Ownable } from "@openzeppelin/contracts/access//Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OnePieceMint is VRFConsumerBaseV2, ERC721, Ownable, ERC721URIStorage {

    // metadata URIs
    string[] internal characterTokenURIs = [
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmNp4sHf4ccqPpqMBUCSG1CpFwFR4D6kgHesxc1mLs75am",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmPHaFt55PeidgCuXe2kaeRYmLaBUPE1Y7Kg4tDyzapZHy",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmP9pC9JuUpKcnjUk8GBXEWVTGvK3FTjXL91Q3MJ2rhA16",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmSnNXo5hxrFnpbyBeb7jY7jhkm5eyknaCXtr8muk31AHK",
		"https://scarlet-live-iguana-759.mypinata.cloud/ipfs/QmarkkgDuBUcnqksatPzU8uNS4o6LTbEtuK43P7Jyth9NH"
];

// local variables
uint256 private s_tokenCounter;
VRFCoordinatorV2Interface private i_vrfCoordinator;
uint64 private i_subscriptionId;
bytes32 private i_keyHash;
uint32 private i_callbackGasLimit;


// mappings
mapping(uint256 => address) private requestIdToSender;
mapping(address => uint256) private userCharacter;
mapping(address => bool) public hasMinted;
mapping(address => uint256) public s_addressToCharacter;

// events to log nft requests
event NftRequested(uint256 requestId, address requester);
event CharacterTraitDetermined(uint256 characterId);
event NftMinted(uint256 characterId, address minter);

// constructor to initialize the contract
constructor (
    address VRFCoordinatorV2Interface,
    uint64 subId, bytes32 keyHash, uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2Address) ERC721("OnePiece NFT", "OPN") {

        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2Address);
        i_subscriptionId = subId;
        i_keyHash = keyHash;
        i_callbackGasLimit - callbackGasLimit;
    }

    // minting function
    function mintNFT(address recipient,  uint256 characterId) internal {
        require(!hasMinted[recipient], "You have already minted");

        /// get next available token
        uint256 tokenId = s_tokenCounter;

        // mint nft and assign it to recipient
        _safeMint(recipient, tokenId);

        // Set the token URI for the minted NFT based on the character ID
        _setTokenURI(tokenId, characterTokenURIs[characterId]);

         // Map the recipient's address to the character ID they received
        s_addressToCharacter[recipient] = characterId;

         // Increment the token counter for the next minting
        s_tokenCounter += 1;

        // Mark the recipient's address as having minted an NFT
        hasMinted[recipient] = true;

        // Emit an event to log the minting of the NFT
        emit NftMinted(characterId, recipient);
    }

    // request nft function
    function requestNFT(uint256[5] memory answers) public {
        // determine character and store it based on provided answers
        userCharacter[msg.sender] = determineCharachter(answers);

        // request random words from VRF coordinator
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            3,
            i_callbackGasLimit,
            1
        );

        // map requestId to the sender's address
        requestIdToSender[requestId] = msg.sender;

        // Emit event to log request for the NFT
        emit NFTRequested(requestId, msg.sender);
    }


    ////////////////////////////////////////////////////
    //// ADD RANDOMNESS TO THE CONTRACT ///////////////
    //////////////////////////////////////////////////

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // get address of the nft owner w/ request ID
        address nftOwner = requestIdToSender[requestId];

        // get character ID determined based on user's traits
        uint256 traitBasedCharacterId = userCharacter[nftOwner];

        // retrieve the first number from provided array
        uint256 randomValue = randomWords[0];

        // Calculate the random character Id based on random value
        uint256 randomCharacterId = (randomValue % 5);

        // calculate final character ID
        uint256 finalCharacterId = (traitBasedCharacterId + randomCharacterId) % 5;

        // Mint the nft to the owner with final character ID
        mintNft(nftOwner, finalCharacterId);

    }


    /////////// DETERMINE CHARACTER///////////
    /////////////////////////////////////////

    function determineCharacter(uint256[5] memory answers) private returns(uint256) {
        // initilize character ID
        uint256 characterId = 0;

        for (uint256 i = 0; i < 5; i++) {
            characterId += answers[i];
        }

        // Calculate the final character ID by taking the remainder when divided by 5 and adding 1
        characterId = (characterId % 5) + 1;

        // Emit event to log the determination of character traits
        emit CharacterTraitDetermined(characterId);

        return characterId;
        
    }
        ////// OVERRIDE FUNCTIONS ///////////
        ////////////////////////////////////

        /**
        * Override the transfer functionality of ERC721 to make it soulbound 
        * This function is called before every token transfer to enforce soulbound
        */

        function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
            //call its parent contract
            super._beforeTokenTransfer(from, to, tokenId, batchSize);

            // Ensure that tokens are only transferred to or from zero address
            require(from == address(0) || to == address(0), "ERROR, This address is not supported");

        }

        /**
        * Override the tokenURI function to ensure compatibility with ERC721URIStorage 
        */

        function tokenURI(uint256 tokenId) public view override (ERC721, ERC721URIStorage) returns(string memory) {
            //call parent contract
            return super.tokenURI(tokenId);
        }

        /**
        * Override the supportsInterface to ensure compatibility with ERC721URIStorage 
        */
        function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns(bool) {
            // call the parent contract
            return super.supportsInterface(interfaceId);
        }

        /**
        * Override the _burn function to ensure compatibility with ERC721URIStorage 
        */

        function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
            // call parent contract
            return super._burn(tokenId);
        }


    }



