// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Types.t.sol";

abstract contract Fees {
    uint256 internal _feePairsCount;
    mapping(uint256 => Types.FeePair) internal _fees;

    constructor() {
        // Pool0 - WETH -> WBTC
        Types.FeePair storage newFee = _fees[_feePairsCount++];
        newFee.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newFee.buyToken = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        newFee.dexName = "UniV3Dex";
        newFee.fee = 500;
        // Pool1 - UNI -> USDC
        newFee = _fees[_feePairsCount++];
        newFee.sellToken = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        newFee.buyToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        newFee.dexName = "UniV3Dex";
        newFee.fee = 3000;
        // Pool2 - CAKE -> WETH
        newFee = _fees[_feePairsCount++];
        newFee.sellToken = 0x152649eA73beAb28c5b49B26eb48f7EAD6d4c898;
        newFee.buyToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newFee.dexName = "PancakeV3Dex";
        newFee.fee = 2500;
        // Pool3 - AAVE -> WETH
        newFee = _fees[_feePairsCount++];
        newFee.sellToken = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
        newFee.buyToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newFee.dexName = "UniV3Dex";
        newFee.fee = 3000;
        // Pool4 - WETH -> 1INCH
        newFee = _fees[_feePairsCount++];
        newFee.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newFee.buyToken = 0x111111111117dC0aa78b770fA6A738034120C302;
        newFee.dexName = "UniV3Dex";
        newFee.fee = 10000;
    }
}
