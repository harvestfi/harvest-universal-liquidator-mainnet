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
        // Pool1 - CAKE -> WETH
        newFee = _fees[_feePairsCount++];
        newFee.sellToken = 0x152649eA73beAb28c5b49B26eb48f7EAD6d4c898;
        newFee.buyToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newFee.dexName = "PancakeV3Dex";
        newFee.fee = 2500;
    }
}
