// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "./IGenericAttribute.sol";
import "../utils/AttributeClass.sol";
import "../utils/Operatable.sol";
import "../utils/Arrays.sol";

contract GenericAttribute is Context, Ownable, Operatable, IGenericAttribute, AttributeClass {
    using Arrays for uint256[];

    struct GenericSettings {
        string name;
        string description;
        uint8 decimals;
        bool flag;
    }

    // attribute ID => settings
    mapping(uint256 => GenericSettings) public attrs;

    // attribute ID => nft ID => balance
    mapping(uint256 => mapping(uint256 => uint256)) private _balances;

    // nft ID => attributes
    mapping(uint256 => uint256[]) public nftAttrs;

    constructor () AttributeClass(1){}

    function name(uint256 _attrId) public view virtual override returns (string memory) {
        return attrs[_attrId].name;
    }

    function description(uint256 _attrId) public view virtual override returns (string memory) {
        return attrs[_attrId].description;
    }

    function getNFTAttrs(uint256 _nftId) public view virtual override returns (uint256[] memory) {
        return nftAttrs[_nftId];
    }

    function attributeDecimals(uint256 _attrId) public view virtual override returns (uint8) {
        return attrs[_attrId].decimals;
    }

    function attributeValue(uint256 _nftId, uint256 _attrId) public view virtual override returns (uint256) {
        return _balances[_attrId][_nftId];
    }

    function create(
        uint256 _id,
        string memory _name,
        string memory _description,
        uint8 _decimals
    ) public virtual override onlyOwner {
        require(!_exists(_id), "GenericAttribute: attribute _id already exists");
        GenericSettings memory settings = GenericSettings({
        name : _name,
        description : _description,
        decimals : _decimals,
        flag : true
        });
        attrs[_id] = settings;

        emit GenericAttributeCreated(_name, _id);
    }

    function attach(
        uint256 _nftId,
        uint256 _attrId,
        uint256 amount
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "GenericAttribute: attribute _id not exists");

        _balances[_attrId][_nftId] += amount;

        nftAttrs[_nftId].push(_attrId);

        emit GenericAttributeAttached(_nftId, _attrId, amount);
    }

    function remove(
        uint256 _nftId,
        uint256 _attrId
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "GenericAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "GenericAttribute: nft has not attached the attribute");

        delete _balances[_attrId][_nftId];

        nftAttrs[_nftId].removeByValue(_attrId);

        emit GenericAttributeRemoved(_nftId, _attrId);
    }

    function increase(
        uint256 _nftId,
        uint256 _attrId,
        uint256 _amount
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "GenericAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "GenericAttribute: nft has not attached the attribute");

        _balances[_attrId][_nftId] += _amount;

        emit GenericAttributeIncrease(_nftId, _attrId, _amount);
    }

    function decrease(
        uint256 _nftId,
        uint256 _attrId,
        uint256 _amount
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "GenericAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "GenericAttribute: nft has not attached the attribute");

        uint256 nftBalance = _balances[_attrId][_nftId];
        require(nftBalance >= _amount);
        _balances[_attrId][_nftId] = nftBalance - _amount;

        emit GenericAttributeDecrease(_nftId, _attrId, _amount);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return attrs[_id].flag;
    }

    function _hasAttr(uint256 _nftId, uint256 _attrId) internal view returns (bool) {
        return _balances[_attrId][_nftId] > 0;
    }
}
