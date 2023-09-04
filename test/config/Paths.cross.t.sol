// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Types.t.sol";

abstract contract CrossDexSwapPaths {
    uint256 internal _crossDexTokenPairCount;
    mapping(uint256 => Types.TokenPair) internal _crossDexTokenPairs;

    constructor() {
        address[] memory _pathA = new address[](2);
        address[] memory _pathB = new address[](2);

        // Pair0 - (UniV3) USDC -> WETH -> BAL (Balancer)
        _pathA[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        _pathA[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _pathB[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _pathB[1] = 0xba100000625a3754423978a60c9317c58a424e3D;

        Types.TokenPair storage newTokenPair = _crossDexTokenPairs[_crossDexTokenPairCount++];
        newTokenPair.sellToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        newTokenPair.buyToken = 0xba100000625a3754423978a60c9317c58a424e3D;
        newTokenPair.whale = 0x171cda359aa49E46Dec45F375ad6c256fdFBD420;
        newTokenPair.dexSetup.push(Types.DexSetting("UniV3Dex", _pathA));
        newTokenPair.dexSetup.push(Types.DexSetting("BalancerDex", _pathB));

        // Pair1 - (UniV3) UNI -> WETH -> SUSHI (Sushi)
        _pathA[0] = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        _pathA[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _pathB[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _pathB[1] = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;

        newTokenPair = _crossDexTokenPairs[_crossDexTokenPairCount++];
        newTokenPair.sellToken = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        newTokenPair.buyToken = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
        newTokenPair.whale = 0xa371D95184127Bf81d1e7281733eB94041E7eB8e;
        newTokenPair.dexSetup.push(Types.DexSetting("UniV3Dex", _pathA));
        newTokenPair.dexSetup.push(Types.DexSetting("SushiswapDex", _pathB));

        // Pair2 - (UniV3) UNI -> USDC -> USDT (Curve)
        _pathA[0] = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        _pathA[1] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        _pathB[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        _pathB[1] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

        newTokenPair = _crossDexTokenPairs[_crossDexTokenPairCount++];
        newTokenPair.sellToken = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
        newTokenPair.buyToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        newTokenPair.whale = 0xa371D95184127Bf81d1e7281733eB94041E7eB8e;
        newTokenPair.dexSetup.push(Types.DexSetting("UniV3Dex", _pathA));
        newTokenPair.dexSetup.push(Types.DexSetting("CurveDex", _pathB));
    }
}
