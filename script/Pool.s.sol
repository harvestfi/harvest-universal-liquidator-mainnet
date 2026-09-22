// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

import "../src/core/dexes/BalancerDex.sol";
import "../src/core/dexes/CurveDex.sol";

/**
 * @notice One route to configure on one dex.
 * @dev The JSON is decoded by key in alphabetical order, so these fields have
 * to stay alphabetical and every entry has to carry every key, empty or not.
 *
 * `path` is the tokens the route passes through, from `sellToken` to
 * `buyToken`; `pools` holds one pool per hop of that path, and `params` --
 * CurveDex only -- the curve router's swap_params for each hop.
 */
struct PoolPair {
    address buyToken;
    string description;
    string dexName;
    uint256[][] params;
    address[] path;
    bytes32[] pools;
    address sellToken;
}

contract PoolScript is Script {
    using stdJson for string;

    string _json;
    string _config;

    function run() public {
        vm.startBroadcast();
        preDeploy();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public {
        PoolPair[] memory _pools = abi.decode(_config.parseRaw(""), (PoolPair[]));
        for (uint256 i; i < _pools.length;) {
            PoolPair memory _entry = _pools[i];
            string memory dexName = _entry.dexName;
            bool isBalancer = keccak256(bytes(dexName)) == keccak256(bytes("BalancerDex"));
            require(
                isBalancer || keccak256(bytes(dexName)) == keccak256(bytes("CurveDex")),
                string.concat("Pool.s.sol cannot configure pools on ", dexName)
            );
            checkEntry(_entry);

            address _dexAddr = _json.readAddress(string.concat(".", vm.envString("NETWORK"), ".", dexName, ".address"));
            console2.log(string.concat("configuring ", dexName, ": ", _entry.description));

            // Both dexes key their config by adjacent pair while the config
            // gives one pool per hop of the route, so each hop is set on its
            // own. The calls are typed rather than raw: a signature the dex
            // does not expose then fails to compile instead of reverting on a
            // broadcast, and a call that does revert takes the script with it.
            if (isBalancer) {
                for (uint256 k; k < _entry.pools.length;) {
                    BalancerDex(payable(_dexAddr)).setPool(_entry.path[k], _entry.path[k + 1], _entry.pools[k]);
                    unchecked {
                        ++k;
                    }
                }
            } else {
                require(
                    _entry.params.length == _entry.pools.length, string.concat(_entry.description, ": one params entry per hop")
                );
                for (uint256 k; k < _entry.pools.length;) {
                    // a pool address in the JSON decodes right-aligned
                    address curvePool = address(uint160(uint256(_entry.pools[k])));
                    CurveDex(payable(_dexAddr))
                        .pairSetup(
                            _entry.path[k], _entry.path[k + 1], curvePool, swapParams(_entry.params[k], _entry.description)
                        );
                    unchecked {
                        ++k;
                    }
                }
            }

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Check that a route's hops and pools line up before sending anything
     */
    function checkEntry(PoolPair memory _entry) internal pure {
        require(_entry.path.length > 1, string.concat(_entry.description, ": path needs at least two tokens"));
        require(_entry.path[0] == _entry.sellToken, string.concat(_entry.description, ": path does not start at sellToken"));
        require(
            _entry.path[_entry.path.length - 1] == _entry.buyToken,
            string.concat(_entry.description, ": path does not end at buyToken")
        );
        require(_entry.pools.length == _entry.path.length - 1, string.concat(_entry.description, ": one pool per hop"));
    }

    /**
     * @notice The curve router's [i, j, swap_type, pool_type, n_coins] for one hop
     */
    function swapParams(uint256[] memory _params, string memory _description) internal pure returns (uint256[5] memory) {
        require(_params.length == 5, string.concat(_description, ": params must hold 5 values per hop"));
        return [_params[0], _params[1], _params[2], _params[3], _params[4]];
    }

    /**
     * @notice Check if the key exist in deployed-addresses.json file
     */
    function preDeploy() public {
        _json = vm.readFile(string.concat(vm.projectRoot(), "/script/deployed-addresses.json"));
        _config = vm.readFile(string.concat(vm.projectRoot(), "/script/config/", vm.envString("SETUP_FILE")));
    }
}
