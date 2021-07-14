// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUpgradableAttribute {
    function name(uint256 _attrId) external view returns (string memory);

    function description(uint256 _attrId) external view returns (string memory);

    function getNFTAttrs(uint256 _nftId) external view returns (uint256[] memory);

    function maxLevel(uint256 _attrId) external view returns (uint8);

    function maxSubLevel(uint256 _attrId) external view returns (uint8);

    function create(uint256 _id, string memory _name, string memory _description, uint8 _level, uint8 _subLevel) external;

    function attach(uint256 _nftId, uint256 _attrId) external;

    function remove(uint256 _nftId, uint256 _attrId) external;

    function upgradeLevel(uint256 _nftId, uint256 _attrId, uint8 _level) external;

    function upgradeSubLevel(uint256 _nftId, uint256 _attrId, uint8 _subLevel) external;

    event UpgradableAttributeCreated(string name, uint256 id);
    event UpgradableAttributeAttached(uint256 nftId, uint256 attrId);
    event UpgradableAttributeRemoved(uint256 nftId, uint256 attrId);
    event AttributeLevelUpgraded(uint256 nftId, uint256 attrId, uint8 level);
    event AttributeSubLevelUpgraded(uint256 nftId, uint256 attrId, uint8 subLevel);
}
