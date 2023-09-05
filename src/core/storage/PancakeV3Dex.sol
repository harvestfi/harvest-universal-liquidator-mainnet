// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract PancakeV3DexStorage {
    mapping(address => mapping(address => uint24)) internal _pairFee;
}
