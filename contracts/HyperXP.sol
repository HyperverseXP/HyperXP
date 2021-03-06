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
        uint64 lastUse; // last time an AP was used
        uint16 minAP;   // the minimum AP for this asset
        uint16 APPE;    // AP per epoch
        uint16 usedAP;  // AP used this epoch
    }
    // address: contract address
    // returns the XP allocated to a given contract
    mapping(address => uint256) public xpAlloc;

    // the number of levels required to increase max apPE
    uint256 public apIncreaseFreq;
    uint256 public baseMaxAPPE;

    uint256 public epoch;
    uint256 public xpPerAP;

    //auction items
    address public boostAuction;
    mapping(address => uint256) public addressBoost;

    constructor() {}

    // 1 ap every 5 minutes. does not stack.
    function availableAP(address collection, uint256 tokenId)
    isHyper(collection)
    public view returns(uint256) {
        ActionInfo memory ai = apBlock[collection][tokenId];
        // if the last use was in this epoch
        if (block.timestamp - ai.lastUse < epoch) {
            return ai.APPE - ai.usedAP;
        } else {
            // if the last use was in the previous epoch, increase up to max
            if (block.timestamp - ai.lastUse <= (epoch * 2)) {
                return (ai.APPE + 1) >= getMaxAPPE(collection, tokenId) ? ai.APPE : ai.APPE + 1; 
            }
            // if the last use was 2 epochs or more ago, decrease down to minAP
            if (block.timestamp - ai.lastUse > (epoch * 2)) {
                return (ai.APPE - 1) < ai.minAP ? ai.minAP : ai.APPE - 1;
            }
        }        
        return (!hyperAddresses[collection] || (block.timestamp - apBlock[collection][tokenId].lastUse < 5 minutes)) 
        ? 0 
        : 1;
    }

    function spendAP(address collection, uint256 tokenId, uint16 amount, address to)
    isHyper(collection)
    isAssetOwner(collection, tokenId)
    external {
        _useAP(collection, tokenId, amount);
        apBlock[collection][tokenId].lastUse = uint64(block.timestamp);
        xpAlloc[to] += amount * (addressBoost[collection] == 0 ? xpPerAP : addressBoost[collection]);
    }

    function _useAP(address collection, uint256 tokenId, uint16 amount)
    internal {
        require(amount <= availableAP(collection, tokenId), "not enough AP");
        ActionInfo memory ai = apBlock[collection][tokenId];
        // if the last use was in this epoch
        if (block.timestamp - ai.lastUse < epoch) {
            // return ap per epoch minus the used ap this epoch
            apBlock[collection][tokenId] = ActionInfo({
                lastUse: uint64(block.timestamp),
                minAP: ai.minAP, 
                APPE: ai.APPE,
                usedAP: ai.usedAP + amount
            });
        } else {

        }
    }

    function awardXP(address collection, uint256 tokenId, uint256 amount) 
    isHyper(collection)
    external {
        require(amount <= xpAlloc[msg.sender], "not enough XP");
        xpAlloc[msg.sender] -= amount;
        xp[collection][tokenId] += amount;
    }

    /// @notice Calculates the level of the specified tokenId from a given collection, defaults to 1
    function getLevel(address collection, uint256 tokenId) 
    public
    view
    returns(uint256) {
        uint256 _xp = xp[collection][tokenId];
        if (_xp < 65) return 1;
        else if (_xp < 70) return 2;
        else {
            return 1 + (sqrt(625+75*_xp)-25)/50; // roughly 15% increase xp per level
        }
    }

    /// @notice Calculates the maximum allowable AP per epoch for a given asset
    function getMaxAPPE(address collection, uint256 tokenId)
    public 
    view
    returns(uint256) {
        return baseMaxAPPE + (getLevel(collection, tokenId) / apIncreaseFreq);
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

    function _setAPIncreaseFrequency(uint256 _freq) 
    external
    onlyOwner {
        apIncreaseFreq = _freq;
    }

    function _setBaseMaxAPPE(uint256 _max)
    external
    onlyOwner {
        baseMaxAPPE = _max;
    }

    function _setEpoch(uint256 _epoch)
    external
    onlyOwner {
        epoch = _epoch;
    }

    function _setXPPerAP(uint256 _xppap)
    external
    onlyOwner {
        xpPerAP = _xppap;
    }

    /// @dev can only be used to lower XP
    function _overrideXP(address collection, uint256 tokenId, uint256 newXP) 
    external 
    onlyOwner {
        if (xp[collection][tokenId] > newXP) {
            xp[collection][tokenId] = newXP;
        }
    }
}

/// @notice Calculates the square root of x, rounding down.
/// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
/// @param x The uint256 number for which to calculate the square root.
/// @return result The result as an uint256.
function sqrt(uint256 x) pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }

    // Calculate the square root of the perfect square of a power of two that is the closest to x.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 0x100000000000000000000000000000000) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 0x10000000000000000) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 0x100000000) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 0x10000) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 0x100) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 0x10) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 0x8) {
        result <<= 1;
    }

    // The operations can never overflow because the result is max 2^127 when it enters this block.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1; // Seven iterations should be enough
        uint256 roundedDownResult = x / result;
        return result >= roundedDownResult ? roundedDownResult : result;
    }
}