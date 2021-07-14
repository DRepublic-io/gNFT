// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Context.sol";

abstract contract Operatable is Context {
    address private _operator;

    event OperatorChanged(address indexed previousOperator, address indexed newOperator);

    /**
     * @dev Initializes the contract setting the deployer as the initial operator.
     */
    constructor () {
        address msgSender = _msgSender();
        _operator = msgSender;
        emit OperatorChanged(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current operator.
     */
    function operator() public view virtual returns (address) {
        return _operator;
    }

    /**
     * @dev Throws if called by any account other than the operator.
     */
    modifier onlyOperator() {
        require(operator() == _msgSender(), "Operatable: caller is not the operator");
        _;
    }

    /**
     * @dev Change operator of the contract.
     * Can only be called by the current operator.
     */
    function changeOperator(address newOperator) public virtual onlyOperator {
        require(newOperator != address(0), "Operatable: new operator is the zero address");
        _operator = newOperator;
    }
}
