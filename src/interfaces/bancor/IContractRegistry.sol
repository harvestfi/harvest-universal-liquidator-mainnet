// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @dev Contract Registry interface
 */
interface IContractRegistry {
    function addressOf(bytes32 contractName) external view returns (address);
}
