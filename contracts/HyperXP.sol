/*
                                          _____          
                                         /\    \         
                                        /::\____\        
                                       /:::/    /        
                                      /:::/    /         
                                     /:::/    /          
                                    /:::/____/           
                                   /::::\    \           
                                  /::::::\    \   _____  
                                 /:::/\:::\    \ /\    \ 
                                /:::/  \:::\    /::\____\
                                \::/    \:::\  /:::/    /
                                 \/____/ \:::\/:::/    / 
                                          \::::::/    /  
                                           \::::/    /   
                                           /:::/    /    
                                          /:::/    /     
                                         /:::/    /      
                                        /:::/    /       
                                        \::/    /        
                                         \/____/                        
                                      _____          
                                     |\    \         
                                     |:\____\        
                                     |::|   |        
                                     |::|   |        
                                     |::|   |        
                                     |::|   |        
                                     |::|   |        
                                     |::|___|______  
                                     /::::::::\    \ 
                                    /::::::::::\____\
                                   /:::/~~~~/~~      
                                  /:::/    /         
                                 /:::/    /          
                                /:::/    /           
                                \::/    /            
                                 \/____/             
                                                               
                                  _____          
        ______                   /\    \         
       |::|   |                 /::\    \        
       |::|   |                /::::\    \       
       |::|   |               /::::::\    \      
       |::|   |              /:::/\:::\    \     
       |::|   |             /:::/__\:::\    \    
       |::|   |            /::::\   \:::\    \   
       |::|   |           /::::::\   \:::\    \  
 ______|::|___|___ ____  /:::/\:::\   \:::\____\ 
|:::::::::::::::::|    |/:::/  \:::\   \:::|    |
|:::::::::::::::::|____|\::/    \:::\  /:::|____|
 ~~~~~~|::|~~~|~~~       \/_____/\:::\/:::/    / 
       |::|   |                   \::::::/    /  
       |::|   |                    \::::/    /   
       |::|   |                     \::/____/    
       |::|   |                      ~~          
       |::|   |                   _____                 
       |::|   |                  /\    \                 
       |::|___|                 /::\    \                    
        ~~                     /::::\    \              
                              /::::::\    \      
                             /:::/\:::\    \     
                            /:::/__\:::\    \    
                           /::::\   \:::\    \   
                          /::::::\   \:::\    \  
                         /:::/\:::\   \:::\    \ 
                        /:::/__\:::\   \:::\____\
                        \:::\   \:::\   \::/    /
                         \:::\   \:::\   \/____/ 
                          \:::\   \:::\    \     
                           \:::\   \:::\____\    
                            \:::\   \::/    /    
                             \:::\   \/____/     
                              \:::\    \         
                               \:::\____\        
                                \::/    /        
                                 \/____/         
                                  _____          
                                 /\    \         
                                /::\    \        
                               /::::\    \       
                              /::::::\    \      
                             /:::/\:::\    \     
                            /:::/__\:::\    \    
                           /::::\   \:::\    \   
                          /::::::\   \:::\    \  
                         /:::/\:::\   \:::\____\ 
                        /:::/  \:::\   \:::|    |
                        \::/   |::::\  /:::|____|
                         \/____|:::::\/:::/    / 
                               |:::::::::/    /  
                               |::|\::::/    /   
                               |::| \::/____/    
                               |::|  ~|          
                               |::|   |          
                               \::|   |          
                                \:|   |          
                                 \|___|                                          
*/
//SPDX-License-Identifier: CC0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//notloot collection: 0x841e03065558AeE39D6Cb2F751DB964f80E95EE3
contract HyperXP is Ownable, ReentrancyGuard {
    // address: collection address
    mapping(address => bool) public hyperAddresses;

    // address: collection address
    // uint256: id of token in collection
    // returns xp of given token from collection
    mapping(address => mapping(uint256 => uint256)) public xp;

    // address: collection address
    // uint256: id of token in collection
    // returns the block of the last Action Point used by given token from collection
    mapping(address => mapping(uint256 => ActionInfo)) public apBlock;
    struct ActionInfo {
        uint128 lastUse; // last time an AP was used
        uint32 apPE;  // AP per epoch
    }
    // address: contract address
    // returns the XP allocated to a given contract
    mapping(address => uint256) public xpAlloc;

    constructor() {}

    // 1 ap every 5 minutes. does not stack.
    function availableAP(address collection, uint256 tokenId)
    isHyper(collection)
    public view returns(uint256) {
        return (!hyperAddresses[collection] || (block.timestamp - apBlock[collection][tokenId].lastUse < 5 minutes)) 
        ? 0 
        : 1;
    }

    function useAP(address collection, uint256 tokenId, uint256 amount, address to)
    isHyper(collection)
    isAssetOwner(collection, tokenId)
    external {
        require(amount <= availableAP(collection, tokenId), "not enough AP");
        apBlock[collection][tokenId].lastUse = uint128(block.timestamp);
        xpAlloc[to] += amount * 200; // 200 XP per AP
    }

    function awardXP(address collection, uint256 tokenId, uint256 amount) 
    isHyper(collection)
    external {
        require(amount <= xpAlloc[msg.sender], "not enough XP");
        xpAlloc[msg.sender] -= amount;
        xp[collection][tokenId] += amount;
    }

    modifier isHyper(address collection) {
        require(hyperAddresses[collection], "not yet in hyper xp");
        _;
    }

    modifier isAssetOwner(address collection, uint256 tokenId) {
        require(IERC721(collection).ownerOf(tokenId) == tx.origin, "you can't perform this action");
        _;
    }

    function _addCollection(address collection) 
    external
    onlyOwner {
        hyperAddresses[collection] = true;
    }

    function _addCollections(address[] calldata collections) 
    external
    onlyOwner {
        for (uint i=0; i < collections.length; i++) {
            hyperAddresses[collections[i]] = true;
        }
    }

    function _removeCollection(address collection) 
    external
    onlyOwner {
        hyperAddresses[collection] = false;
    }
}