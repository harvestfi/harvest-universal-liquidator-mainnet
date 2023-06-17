// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// import test base and helpers.
import "forge-std/Test.sol";

import "../src/core/UniversalLiquidator.sol";
import "../src/core/UniversalLiquidatorRegistry.sol";

import "../src/core/dexes/UniV3Dex.sol";
import "../src/core/dexes/BalancerDex.sol";
import "../src/core/dexes/SushiswapDex.sol";
import "../src/core/dexes/CurveDex.sol";

import "./config/Env.t.sol";
import "./config/Types.t.sol";
import "./config/Paths.single.t.sol";
import "./config/Paths.multi.t.sol";
import "./config/Paths.cross.t.sol";
import "./config/Pools.t.sol";
import "./config/Fees.t.sol";

abstract contract AdvancedFixture is
    Test,
    SingleSwapPaths,
    MultiSwapPaths,
    CrossDexSwapPaths,
    Pools,
    Fees,
    EnvVariables,
    Types
{
    uint256 _polygonFork;

    UniversalLiquidator internal _universalLiquidator;
    UniversalLiquidatorRegistry internal _universalLiquidatorRegistry;

    UniV3Dex internal _uniV3Dex;
    BalancerDex internal _balancerDex;
    SushiswapDex internal _sushiswapDex;
    CurveDex internal _curveDex;

    string[] internal _dexes;
    mapping(string => Dex) internal _dexesByName;
    address[] internal _intermediateTokens = [
        0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619, // WETH
        0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, // WMATIC
        0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, // USDC
        0xc2132D05D31c914a87C6611C10748AEb04B58e8F // USDT
    ];

    constructor() {
        startHoax(EnvVariables._governance);
        // fork testing environment
        _polygonFork = vm.createFork(_POLYGON_RPC_URL);
        vm.selectFork(_polygonFork);
        // deploy UL, ULR, and dexes
        _universalLiquidatorRegistry = new UniversalLiquidatorRegistry();
        _universalLiquidator = new UniversalLiquidator();
        _universalLiquidator.setPathRegistry(address(_universalLiquidatorRegistry));
        vm.stopPrank();
    }

    function _setupDexes() internal {
        _uniV3Dex = new UniV3Dex();
        _dexes.push("UniV3Dex");
        _dexesByName["UniV3Dex"] = Dex(address(_uniV3Dex), bytes32(bytes("uniV3")));
        _universalLiquidatorRegistry.addDex(bytes32(bytes("uniV3")), address(_uniV3Dex));

        _balancerDex = new BalancerDex();
        _dexes.push("BalancerDex");
        _dexesByName["BalancerDex"] = Dex(address(_balancerDex), bytes32(bytes("balancer")));
        _universalLiquidatorRegistry.addDex(bytes32(bytes("balancer")), address(_balancerDex));

        _sushiswapDex = new SushiswapDex();
        _dexes.push("SushiswapDex");
        _dexesByName["SushiswapDex"] = Dex(address(_sushiswapDex), bytes32(bytes("sushi")));
        _universalLiquidatorRegistry.addDex(bytes32(bytes("sushi")), address(_sushiswapDex));

        _curveDex = new CurveDex();
        _dexes.push("CurveDex");
        _dexesByName["CurveDex"] = Dex(address(_curveDex), bytes32(bytes("curve")));
        _universalLiquidatorRegistry.addDex(bytes32(bytes("curve")), address(_curveDex));
    }

    function _setupPools() internal {
        for (uint256 i; i < _poolPairsCount;) {
            string memory dexName = _pools[i].dexName;
            address dexAddress = _dexesByName[_pools[i].dexName].addr;
            if (keccak256(bytes(dexName)) == keccak256(bytes("BalancerDex"))) {
                (bool success, bytes memory data) = dexAddress.call(
                    abi.encodeWithSignature(
                        "setPool(address,address,bytes32[])", _pools[i].sellToken, _pools[i].buyToken, _pools[i].pools
                    )
                );
                if (!success) {
                    console2.log("curve setPool failed: ");
                    console2.logBytes(data);
                }
            } else if (keccak256(bytes(dexName)) == keccak256(bytes("CurveDex"))) {
                (bool success, bytes memory data) = dexAddress.call(
                    abi.encodeWithSignature(
                        "setPool(address,address,address)",
                        _pools[i].sellToken,
                        _pools[i].buyToken,
                        address(bytes20(_pools[i].pools[0]))
                    )
                );
                if (!success) {
                    console2.log("curve setPool failed: ");
                    console2.logBytes(data);
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    function _setupFees() internal {
        for (uint256 i; i < _feePairsCount;) {
            string memory dexName = _fees[i].dexName;
            address dexAddress = _dexesByName[_fees[i].dexName].addr;
            if (keccak256(bytes(dexName)) == keccak256(bytes("UniV3Dex"))) {
                (bool success, bytes memory data) = dexAddress.call(
                    abi.encodeWithSignature("setFee(address,address,uint24)", _fees[i].sellToken, _fees[i].buyToken, _fees[i].fee)
                );
                if (!success) {
                    console2.log("curve setPool failed: ");
                    console2.logBytes(data);
                }
            }
            unchecked {
                ++i;
            }
        }
    }
}
