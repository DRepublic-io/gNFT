// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract AttributeClass {
    // 1 => Generic,
    // 2 => Upgradable,
    // 3 => Transferable,
    // 4 => Evolutive
    // more expand...
    uint16 private _class;

    constructor (uint16 class_) {
        _class = class_;
    }

    /**
     * @dev Returns the class of the attribute.
     */
    function class() public view virtual returns (uint16) {
        return _class;
    }
}
