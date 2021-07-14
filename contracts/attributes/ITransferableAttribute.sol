// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITransferableAttribute {
    function name(uint256 _attrId) external view returns (string memory);

    function description(uint256 _attrId) external view returns (string memory);

    function getNFTAttrs(uint256 _nftId) external view returns (uint256[] memory);

    function attributeDecimals(uint256 _attrId) external view returns (uint8);

    function attributeValue(uint256 _nftId, uint256 _attrId) external view returns (uint256);

    function create(uint256 _id, string memory _name, string memory _description, uint8 _decimals) external;

    function attach(uint256 _nftId, uint256 _attrId,  uint256 amount) external;

    function remove(uint256 _nftId, uint256 _attrId) external;

    function approve(uint256 _from, uint256 _to, uint256 _attrId) external;

    function transferFrom(uint256 _from, uint256 _to, uint256 _attrId) external;

    event TransferableAttributeCreated(string name, uint256 id);
    event TransferableAttributeAttached(uint256 nftId, uint256 attrId, uint256 amount);
    event TransferableAttributeApproval(uint256 from, uint256 to, uint256 attrId);
    event TransferableAttributeRemoved(uint256 nftId, uint256 attrId);
    event TransferableAttributeTransfer(uint256 from, uint256 to);
}
