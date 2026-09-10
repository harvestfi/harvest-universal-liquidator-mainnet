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

        // No curve pools: CurveDex swaps through _CURVE_ROUTER
        // (0x16C6521Dff6baB339122a0FE25a9116693265353), which has no code at
        // the block this suite forks from, 18084195 -- the router was deployed
        // at block 20189560, on 2024-06-28. Every curve swap therefore reverts
        // here, so the pairs that used it are gone from the swap paths too.
        // Restoring any of this needs a newer fork block, and note that this
        // dex takes pairSetup(address,address,address,uint256[5]), not setPool.
    }
}
