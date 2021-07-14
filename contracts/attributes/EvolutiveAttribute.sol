// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "./IEvolutiveAttribute.sol";
import "../IGameNFTs.sol";
import "../utils/AttributeClass.sol";
import "../utils/Operatable.sol";
import "../utils/Arrays.sol";

contract EvolutiveAttribute is IEvolutiveAttribute, Context, Ownable, Operatable, AttributeClass {
    using Arrays for uint256[];

    struct EvolutiveSettings {
        string name;
        string description;
        uint8 level;
        // Probability in basis points (out of 100) of receiving each level (descending)
        uint8[] probabilities;
        // Block interval required for evolutive
        uint256[] evolutiveIntervals;
    }

    struct EvolutiveState {
        uint8 level;
        uint256 createBlock;
        uint256 evolutiveBlock;
        bool status; // normal or broken
    }

    address private _nftAddress;

    // attribute ID => settings
    mapping(uint256 => EvolutiveSettings) public attrs;

    // attribute ID => nft ID => State
    mapping(uint256 => mapping(uint256 => EvolutiveState)) private _states;

    // nft ID => attributes
    mapping(uint256 => uint256[]) public nftAttrs;

    modifier onlyCreator(uint256 id) {
        require(IGameNFTs(_nftAddress).creatorOf(id) == _msgSender(), "EvolutiveAttribute: caller is not the nft creator");
        _;
    }

    constructor (address nftAddress_) AttributeClass(4){
        _nftAddress = nftAddress_;
    }

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

    function create(
        uint256 _id,
        string memory _name,
        string memory _description,
        uint8 _level,
        uint8[] memory _probabilities,
        uint256[] memory _evolutiveIntervals
    ) public virtual override onlyOwner {
        require(!_exists(_id), "EvolutiveAttribute: attribute _id already exists");
        require(_probabilities.length == _level, "EvolutiveAttribute: invalid probabilities");
        require(_evolutiveIntervals.length == _level, "EvolutiveAttribute: invalid evolutiveIntervals");

        EvolutiveSettings memory settings = EvolutiveSettings({
        name : _name,
        description : _description,
        level : _level,
        probabilities : _probabilities,
        evolutiveIntervals : _evolutiveIntervals
        });
        attrs[_id] = settings;

        emit EvolutiveAttributeCreated(_name, _id);
    }

    function attach(
        uint256 _nftId,
        uint256 _attrId
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "EvolutiveAttribute: attribute _id not exists");
        require(!_hasAttr(_nftId, _attrId), "EvolutiveAttribute: nft has attached the attribute");

        _states[_attrId][_nftId] = EvolutiveState({
        level : 1,
        createBlock : block.number,
        evolutiveBlock : block.number + attrs[_attrId].evolutiveIntervals[0],
        status : true
        });

        nftAttrs[_nftId].push(_attrId);

        emit EvolutiveAttributeAttached(_nftId, _attrId);
    }

    function remove(
        uint256 _nftId,
        uint256 _attrId
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "EvolutiveAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "EvolutiveAttribute: nft has not attached the attribute");

        delete _states[_attrId][_nftId];

        nftAttrs[_nftId].removeByValue(_attrId);

        emit EvolutiveAttributeRemoved(_nftId, _attrId);
    }

    function evolutive(
        uint256 _nftId,
        uint256 _attrId,
        uint8 _level
    ) public virtual override onlyCreator(_nftId) {
        require(_exists(_attrId), "EvolutiveAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "EvolutiveAttribute: nft has not attached the attribute");
        require(_isNormal(_nftId, _attrId), "EvolutiveAttribute: nft is broken");
        require(_level <= attrs[_attrId].level, "EvolutiveAttribute: exceeded the maximum level");
        require(_level == _states[_attrId][_nftId].level + 1, "EvolutiveAttribute: invalid level");
        require(block.number >= _states[_attrId][_nftId].evolutiveBlock, "EvolutiveAttribute: did not reach evolution time");

        // TODO random evolutive
        _states[_attrId][_nftId].level = _level;

        emit AttributeEvolutive(_nftId, _attrId, _level);
    }

    function repair(
        uint256 _nftId,
        uint256 _attrId
    ) public virtual override onlyCreator(_nftId) {
        require(_exists(_attrId), "EvolutiveAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "EvolutiveAttribute: nft has not attached the attribute");
        require(!_isNormal(_nftId, _attrId), "EvolutiveAttribute: nft is normal");

        uint8 level = _states[_attrId][_nftId].level;
        _states[_attrId][_nftId].status = true;
        _states[_attrId][_nftId].evolutiveBlock = block.number + attrs[_attrId].evolutiveIntervals[level - 1];

        emit AttributeRepaired(_nftId, _attrId);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return attrs[_id].level > 0;
    }

    function _hasAttr(uint256 _nftId, uint256 _attrId) internal view returns (bool) {
        return _states[_attrId][_nftId].level > 0;
    }

    function _isNormal(uint256 _nftId, uint256 _attrId) internal view returns (bool) {
        return _states[_attrId][_nftId].status;
    }

}
