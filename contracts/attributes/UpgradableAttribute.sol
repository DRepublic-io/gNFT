// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "./IUpgradableAttribute.sol";
import "../utils/AttributeClass.sol";
import "../utils/Operatable.sol";
import "../utils/Arrays.sol";

contract UpgradableAttribute is IUpgradableAttribute, Context, Ownable, Operatable, AttributeClass {
    using Arrays for uint256[];

    struct UpgradableSettings {
        string name;
        string description;
        uint8 level;
        uint8 subLevel;
    }

    struct UpgradeState {
        uint8 level;
        uint8 subLevel;
    }

    // attribute ID => settings
    mapping(uint256 => UpgradableSettings) public attrs;

    // attribute ID => nft ID => Level
    mapping(uint256 => mapping(uint256 => UpgradeState)) private _states;

    // nft ID => attributes
    mapping(uint256 => uint256[]) public nftAttrs;

    constructor () AttributeClass(2){}

    function name(uint256 _attrId) public view virtual override returns (string memory) {
        return attrs[_attrId].name;
    }

    function description(uint256 _attrId) public view virtual override returns (string memory) {
        return attrs[_attrId].description;
    }

    function getNFTAttrs(uint256 _nftId) public view virtual override returns (uint256[] memory) {
        return nftAttrs[_nftId];
    }

    function maxLevel(uint256 _attrId) public view virtual override returns (uint8) {
        return attrs[_attrId].level;
    }

    function maxSubLevel(uint256 _attrId) public view virtual override returns (uint8) {
        return attrs[_attrId].subLevel;
    }

    function create(
        uint256 _id,
        string memory _name,
        string memory _description,
        uint8 _level,
        uint8 _subLevel
    ) public virtual override onlyOwner {
        require(!_exists(_id), "UpgradableAttribute: attribute _id already exists");
        UpgradableSettings memory settings = UpgradableSettings({
        name : _name,
        description : _description,
        level : _level,
        subLevel : _subLevel
        });
        attrs[_id] = settings;

        emit UpgradableAttributeCreated(_name, _id);
    }

    function attach(
        uint256 _nftId,
        uint256 _attrId
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "UpgradableAttribute: attribute _id not exists");
        require(!_hasAttr(_nftId, _attrId), "UpgradableAttribute: nft has attached the attribute");

        _states[_attrId][_nftId] = UpgradeState({
        level : 1,
        subLevel : 1
        });

        nftAttrs[_nftId].push(_attrId);

        emit UpgradableAttributeAttached(_nftId, _attrId);
    }

    function remove(
        uint256 _nftId,
        uint256 _attrId
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "UpgradableAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "UpgradableAttribute: nft has not attached the attribute");

        delete _states[_attrId][_nftId];

        nftAttrs[_nftId].removeByValue(_attrId);

        emit UpgradableAttributeRemoved(_nftId, _attrId);
    }

    function upgradeLevel(
        uint256 _nftId,
        uint256 _attrId,
        uint8 _level
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "UpgradableAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "UpgradableAttribute: nft has not attached the attribute");

        require(_level <= attrs[_attrId].level, "UpgradableAttribute: exceeded the maximum level");
        require(_level == _states[_attrId][_nftId].level + 1, "UpgradableAttribute: invalid level");

        _states[_attrId][_nftId].level = _level;

        emit AttributeLevelUpgraded(_nftId, _attrId, _level);
    }

    function upgradeSubLevel(
        uint256 _nftId,
        uint256 _attrId,
        uint8 _subLevel
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "UpgradableAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "UpgradableAttribute: nft has not attached the attribute");

        UpgradeState memory state = _states[_attrId][_nftId];

        require(_subLevel <= attrs[_attrId].subLevel, "UpgradableAttribute: exceeded the maximum subLevel");
        require(_subLevel == state.subLevel + 1, "UpgradableAttribute: invalid subLevel");

        state.subLevel = _subLevel;
        _states[_attrId][_nftId] = state;

        emit AttributeSubLevelUpgraded(_nftId, _attrId, _subLevel);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return attrs[_id].level > 0;
    }

    function _hasAttr(uint256 _nftId, uint256 _attrId) internal view returns (bool) {
        return _states[_attrId][_nftId].level > 0;
    }
}
