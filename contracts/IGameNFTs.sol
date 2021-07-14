// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the NFT attribute.
 */
interface IGameNFTs {
    function creatorOf(uint256 _id) external view returns (address);
}
