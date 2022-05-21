//SPDX-License-Identifier: CC0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IHXP.sol";

// a contract that will use APs from allowed collections and award XP
contract HXPClient is Ownable, ReentrancyGuard {
    IHXP public hyperXP;
    constructor() {}

    function _setHyperXP(address _hxp) 
    external 
    onlyOwner {
        hyperXP = IHXP(_hxp);
    }

    function simpleAction(address collection, uint256 tokenId) 
    external {
        hyperXP.useAP(collection, tokenId, 1, address(this));
        hyperXP.awardXP(collection, tokenId, 50);
    }

    function largeAction(address collection, uint256 tokenId) 
    external {
        hyperXP.useAP(collection, tokenId, 1, address(this));
        hyperXP.awardXP(collection, tokenId, 500);
    }
}