// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "./ITransferableAttribute.sol";
import "../IGameNFTs.sol";
import "../utils/AttributeClass.sol";
import "../utils/Operatable.sol";
import "../utils/Arrays.sol";

/**
 * @dev Implementation of the {INFTAttr} interface.
 */
contract TransferableAttribute is ITransferableAttribute, Context, Ownable, Operatable, AttributeClass {
    using Arrays for uint256[];

    struct TransferableSettings {
        string name;
        string description;
        uint8 decimals;
        bool flag;
    }

    address private _nftAddress;

    // attribute ID => settings
    mapping(uint256 => TransferableSettings) public attrs;

    // attribute ID => nft ID => balance
    mapping(uint256 => mapping(uint256 => uint256)) private _balances;

    // attribute ID => nft ID => other nft ID
    mapping(uint256 => mapping(uint256 => uint256)) private _allowances;

    // nft ID => attributes
    mapping(uint256 => uint256[]) public nftAttrs;

    modifier onlyCreator(uint256 id) {
        require(IGameNFTs(_nftAddress).creatorOf(id) == _msgSender(), "TransferableAttribute: caller is not the nft creator");
        _;
    }

    constructor (address nftAddress_) AttributeClass(3){
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
        require(!_exists(_id), "TransferableAttribute: attribute _id already exists");
        TransferableSettings memory settings = TransferableSettings({
        name : _name,
        description : _description,
        decimals : _decimals,
        flag : true
        });
        attrs[_id] = settings;

        emit TransferableAttributeCreated(_name, _id);
    }

    function attach(
        uint256 _nftId,
        uint256 _attrId,
        uint256 amount
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "TransferableAttribute: attribute _id not exists");

        _balances[_attrId][_nftId] += amount;

        nftAttrs[_nftId].push(_attrId);

        emit TransferableAttributeAttached(_nftId, _attrId, amount);
    }

    function remove(
        uint256 _nftId,
        uint256 _attrId
    ) public virtual override onlyOperator {
        require(_exists(_attrId), "TransferableAttribute: attribute _id not exists");
        require(_hasAttr(_nftId, _attrId), "TransferableAttribute: nft has not attached the attribute");

        delete _balances[_attrId][_nftId];

        nftAttrs[_nftId].removeByValue(_attrId);

        emit TransferableAttributeRemoved(_nftId, _attrId);
    }

    function approve(
        uint256 _from,
        uint256 _to,
        uint256 _attrId)
    public virtual override onlyCreator(_from) {
        require(_from != 0, "TransferableAttribute: approve from the zero address");
        require(_to != 0, "TransferableAttribute: approve to the zero address");
        require(!_hasAttr(_to, _attrId), "TransferableAttribute: recipient nft has attached the attribute");

        _allowances[_attrId][_from] = _to;
        emit TransferableAttributeApproval(_from, _to, _attrId);
    }

    function transferFrom(
        uint256 _from,
        uint256 _to,
        uint256 _attrId
    ) public virtual override onlyOperator {
        require(_from != 0, "TransferableAttribute: transfer from the zero address");
        require(_to != 0, "TransferableAttribute: transfer to the zero address");
        require(!_hasAttr(_to, _attrId), "TransferableAttribute: recipient has attached the attribute");
        require(_hasApproved(_from, _to, _attrId), "TransferableAttribute: nft creator not approve the attribute to recipient");

        uint256 amount = _balances[_attrId][_from];
        _balances[_attrId][_to] = amount;
        delete _balances[_attrId][_from];
        delete _allowances[_attrId][_from];

        emit TransferableAttributeTransfer(_from, _to);
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return attrs[_id].flag;
    }

    function _hasAttr(uint256 _nftId, uint256 _attrId) internal view returns (bool) {
        return _balances[_attrId][_nftId] > 0;
    }

    function _hasApproved(uint256 _from, uint256 _to, uint256 _attrId) internal view returns (bool) {
        return _allowances[_attrId][_from] == _to;
    }
}
