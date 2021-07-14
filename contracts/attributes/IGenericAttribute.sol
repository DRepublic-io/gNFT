// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGenericAttribute {
    function name(uint256 _attrId) external view returns (string memory);

    function description(uint256 _attrId) external view returns (string memory);

    function getNFTAttrs(uint256 _nftId) external view returns (uint256[] memory);

    function attributeDecimals(uint256 _attrId) external view returns (uint8);

    function attributeValue(uint256 _nftId, uint256 _attrId) external view returns (uint256);

    function create(uint256 _id, string memory _name, string memory _description, uint8 _decimals) external;

    function attach(uint256 _nftId, uint256 _attrId,  uint256 amount) external;

    function remove(uint256 _nftId, uint256 _attrId) external;

    function increase(uint256 _nftId, uint256 _attrId, uint256 _amount) external;

    function decrease(uint256 _nftId, uint256 _attrId, uint256 _amount) external;

    event GenericAttributeCreated(string name, uint256 id);
    event GenericAttributeAttached(uint256 nftId, uint256 attrId, uint256 amount);
    event GenericAttributeRemoved(uint256 nftId, uint256 attrId);
    event GenericAttributeIncrease(uint256 nftId, uint256 attrId, uint256 amount);
    event GenericAttributeDecrease(uint256 nftId, uint256 attrId, uint256 amount);
}
