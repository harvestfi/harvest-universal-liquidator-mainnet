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
import "../src/core/dexes/BancorV2Dex.sol";
import "../src/core/dexes/PancakeV3Dex.sol";

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
    uint256 _forkNetwork;

    UniversalLiquidator internal _universalLiquidator;
    UniversalLiquidatorRegistry internal _universalLiquidatorRegistry;

    UniV3Dex internal _uniV3Dex;
    BalancerDex internal _balancerDex;
    SushiswapDex internal _sushiswapDex;
    CurveDex internal _curveDex;
    BancorV2Dex internal _bancorV2Dex;
    PancakeV3Dex internal _pancakeV3Dex;

    string[] internal _dexes;
    mapping(string => Dex) internal _dexesByName;
    address[] internal _intermediateTokens = [
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // WETH
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
        0xdAC17F958D2ee523a2206206994597C13D831ec7 // USDT
    ];

    constructor() {
        startHoax(EnvVariables._governance);
        // fork testing environment
        _forkNetwork = vm.createFork(_RPC_URL);
        vm.selectFork(_forkNetwork);
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

        _bancorV2Dex = new BancorV2Dex();
        _dexes.push("BancorV2Dex");
        _dexesByName["BancorV2Dex"] = Dex(address(_bancorV2Dex), bytes32(bytes("bancorV2")));
        _universalLiquidatorRegistry.addDex(bytes32(bytes("bancorV2")), address(_bancorV2Dex));

        _pancakeV3Dex = new PancakeV3Dex();
        _dexes.push("PancakeV3Dex");
        _dexesByName["PancakeV3Dex"] = Dex(address(_pancakeV3Dex), bytes32(bytes("pancakeV3")));
        _universalLiquidatorRegistry.addDex(bytes32(bytes("pancakeV3")), address(_pancakeV3Dex));
    }

    function _setupPools() internal {
        for (uint256 i; i < _poolPairsCount;) {
            string memory dexName = _pools[i].dexName;
            address dexAddress = _dexesByName[_pools[i].dexName].addr;
            if (keccak256(bytes(dexName)) == keccak256(bytes("BalancerDex"))) {
                (bool success, bytes memory data) = dexAddress.call(
                    abi.encodeWithSignature(
                        "setPool(address,address,bytes32)", _pools[i].sellToken, _pools[i].buyToken, _pools[i].pool
                    )
                );
                if (!success) {
                    console2.log("Balancer setPool failed: ");
                    console2.logBytes(data);
                }
            } else if (keccak256(bytes(dexName)) == keccak256(bytes("CurveDex"))) {
                (bool success, bytes memory data) = dexAddress.call(
                    abi.encodeWithSignature(
                        "setPool(address,address,address)",
                        _pools[i].sellToken,
                        _pools[i].buyToken,
                        address(bytes20(_pools[i].pool))
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
            if (
                keccak256(bytes(dexName)) == keccak256(bytes("UniV3Dex"))
                    || keccak256(bytes(dexName)) == keccak256(bytes("PancakeV3Dex"))
            ) {
                (bool success, bytes memory data) = dexAddress.call(
                    abi.encodeWithSignature("setFee(address,address,uint24)", _fees[i].sellToken, _fees[i].buyToken, _fees[i].fee)
                );
                if (!success) {
                    console2.log("setFee failed: ");
                    console2.logBytes(data);
                }
            }
            unchecked {
                ++i;
            }
        }
    }
}
