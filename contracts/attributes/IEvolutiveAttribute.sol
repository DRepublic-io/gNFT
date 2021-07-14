// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEvolutiveAttribute {
    function name(uint256 _attrId) external view returns (string memory);

    function description(uint256 _attrId) external view returns (string memory);

    function getNFTAttrs(uint256 _nftId) external view returns (uint256[] memory);

    function maxLevel(uint256 _attrId) external view returns (uint8);

    function create(
        uint256 _id,
        string memory _name,
        string memory _description,
        uint8 _level,
        uint8[] memory _probabilities,
        uint256[] memory _block_intervals
    ) external;

    function attach(uint256 _nftId, uint256 _attrId) external;

    function remove(uint256 _nftId, uint256 _attrId) external;

    function evolutive(uint256 _nftId, uint256 _attrId, uint8 _level) external;

    function repair(uint256 _nftId, uint256 _attrId) external;

    event EvolutiveAttributeCreated(string name, uint256 id);
    event EvolutiveAttributeAttached(uint256 nftId, uint256 attrId);
    event EvolutiveAttributeRemoved(uint256 nftId, uint256 attrId);
    event AttributeEvolutive(uint256 nftId, uint256 attrId, uint8 level);
    event AttributeRepaired(uint256 nftId, uint256 attrId);
}
