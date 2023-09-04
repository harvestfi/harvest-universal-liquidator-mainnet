// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Types.t.sol";

abstract contract Pools {
    uint256 internal _poolPairsCount;
    mapping(uint256 => Types.PoolPair) internal _pools;

    constructor() {
        bytes32 _curPool;

        // Pool0 - WETH -> BAL
        _curPool = 0x5c6ee304399dbdb9c8ef030ab642b10820db8f56000200000000000000000014;

        Types.PoolPair storage newPool = _pools[_poolPairsCount++];
        newPool.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newPool.buyToken = 0xba100000625a3754423978a60c9317c58a424e3D;
        newPool.dexName = "BalancerDex";
        newPool.pool = _curPool;

        // Pool1 - WETH -> AURA
        _curPool = 0xcfca23ca9ca720b6e98e3eb9b6aa0ffc4a5c08b9000200000000000000000274;

        newPool = _pools[_poolPairsCount++];
        newPool.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newPool.buyToken = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
        newPool.dexName = "BalancerDex";
        newPool.pool = _curPool;

        // Pool2 - BAL -> rETH
        _curPool = 0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112;

        newPool = _pools[_poolPairsCount++];
        newPool.sellToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        newPool.buyToken = 0xae78736Cd615f374D3085123A210448E74Fc6393;
        newPool.dexName = "BalancerDex";
        newPool.pool = _curPool;

        // Pool3 - USDC -> DAI
        _curPool = bytes20(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);

        newPool = _pools[_poolPairsCount++];
        newPool.sellToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        newPool.buyToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        newPool.dexName = "CurveDex";
        newPool.pool = _curPool;

        // Pool4 - DAI -> USDT
        _curPool = bytes20(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);

        newPool = _pools[_poolPairsCount++];
        newPool.sellToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        newPool.buyToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        newPool.dexName = "CurveDex";
        newPool.pool = _curPool;

        // Pool5 - USDT -> FRAX
        _curPool = bytes20(0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B);

        newPool = _pools[_poolPairsCount++];
        newPool.sellToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        newPool.buyToken = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
        newPool.dexName = "CurveDex";
        newPool.pool = _curPool;

        // Pool6 - USDC -> USDT
        _curPool = bytes20(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);

        newPool = _pools[_poolPairsCount++];
        newPool.sellToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        newPool.buyToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        newPool.dexName = "CurveDex";
        newPool.pool = _curPool;
    }
}
