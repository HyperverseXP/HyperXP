//SPDX-License-Identifier: CC0
pragma solidity ^0.8.9;

interface IHXP {
    function useAP(address collection, uint256 tokenId, uint256 amount, address to) external;
    function awardXP(address collection, uint256 tokenId, uint256 amount) external;
    function getLevel(address collection, uint256 tokenId) external view returns (uint256);
}