// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Types.t.sol";

abstract contract MultiSwapPaths {
    uint256 internal _multiTokenPairCount;
    mapping(uint256 => Types.TokenPair) internal _multiTokenPairs;

    constructor() {
        address[] memory _path = new address[](3);

        // Pair0 - AAVE -> WETH -> 1INCH
        _path[0] = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
        _path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _path[2] = 0x111111111117dC0aa78b770fA6A738034120C302;

        Types.TokenPair storage newTokenPair = _multiTokenPairs[_multiTokenPairCount++];
        newTokenPair.sellToken = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
        newTokenPair.buyToken = 0x111111111117dC0aa78b770fA6A738034120C302;
        newTokenPair.whale = 0x0548F59fEE79f8832C299e01dCA5c76F034F558e;
        newTokenPair.dexSetup.push(Types.DexSetting("UniV3Dex", _path));

        // Pair1 - BAL -> WETH -> rETH
        _path[0] = 0xba100000625a3754423978a60c9317c58a424e3D;
        _path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _path[2] = 0xae78736Cd615f374D3085123A210448E74Fc6393;

        newTokenPair = _multiTokenPairs[_multiTokenPairCount++];
        newTokenPair.sellToken = 0xba100000625a3754423978a60c9317c58a424e3D;
        newTokenPair.buyToken = 0xae78736Cd615f374D3085123A210448E74Fc6393;
        newTokenPair.whale = 0xeb54417FA789cEF92b636b69154d92217E4b23f3;
        newTokenPair.dexSetup.push(Types.DexSetting("BalancerDex", _path));

        // Pair2 - SUSHI -> WETH -> AAVE
        _path[0] = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
        _path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _path[2] = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

        newTokenPair = _multiTokenPairs[_multiTokenPairCount++];
        newTokenPair.sellToken = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
        newTokenPair.buyToken = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
        newTokenPair.whale = 0x0990165a42B2c4fc00B71e5dbaA5Be6B3B11c953;
        newTokenPair.dexSetup.push(Types.DexSetting("SushiswapDex", _path));

        // Pair3 - WETH -> BNT -> FARM
        _path = new address[](2);
        _path[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        _path[1] = 0xa0246c9032bC3A600820415aE600c6388619A14D;

        newTokenPair = _multiTokenPairs[_multiTokenPairCount++];
        newTokenPair.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newTokenPair.buyToken = 0xa0246c9032bC3A600820415aE600c6388619A14D;
        newTokenPair.whale = 0x4F4495243837681061C4743b74B3eEdf548D56A5;
        newTokenPair.dexSetup.push(Types.DexSetting("BancorV2Dex", _path));
    }
}
