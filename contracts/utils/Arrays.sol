// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    function find(uint256[] storage values, uint value) public view returns(uint) {
        uint i = 0;
        while (values[i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint256[] storage values, uint value) public {
        uint i = find(values, value);
        delete values[i];
    }
}
