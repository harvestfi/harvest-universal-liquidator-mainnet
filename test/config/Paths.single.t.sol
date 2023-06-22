// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Types.t.sol";

abstract contract SingleSwapPaths {
    uint256 internal _singleTokenPairCount;
    mapping(uint256 => Types.TokenPair) internal _singleTokenPairs;

    constructor() {
        address[] memory _path = new address[](2);

        // Pair0 - WETH -> WBTC
        _path[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _path[1] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

        Types.TokenPair storage newTokenPair = _singleTokenPairs[_singleTokenPairCount++];
        newTokenPair.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newTokenPair.buyToken = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        newTokenPair.whale = 0x8EB8a3b98659Cce290402893d0123abb75E3ab28;
        newTokenPair.dexSetup.push(Types.DexSetting("UniV3Dex", _path));

        // Pair1 - WETH -> AURA
        _path[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _path[1] = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;

        newTokenPair = _singleTokenPairs[_singleTokenPairCount++];
        newTokenPair.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newTokenPair.buyToken = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
        newTokenPair.whale = 0x4F4495243837681061C4743b74B3eEdf548D56A5;
        newTokenPair.dexSetup.push(Types.DexSetting("BalancerDex", _path));

        // Pair2 - WETH -> SUSHI
        _path[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _path[1] = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;

        newTokenPair = _singleTokenPairs[_singleTokenPairCount++];
        newTokenPair.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newTokenPair.buyToken = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
        newTokenPair.whale = 0x8EB8a3b98659Cce290402893d0123abb75E3ab28;
        newTokenPair.dexSetup.push(Types.DexSetting("SushiswapDex", _path));

        // Pair3 - USDC -> DAI
        _path[0] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        _path[1] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

        newTokenPair = _singleTokenPairs[_singleTokenPairCount++];
        newTokenPair.sellToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        newTokenPair.buyToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        newTokenPair.whale = 0x171cda359aa49E46Dec45F375ad6c256fdFBD420;
        newTokenPair.dexSetup.push(Types.DexSetting("CurveDex", _path));
    }
}
