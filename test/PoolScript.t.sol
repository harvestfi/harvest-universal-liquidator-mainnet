// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "../script/Pool.s.sol";

/**
 * @notice Runs the pool setup script against freshly deployed dexes
 * @dev The test inherits the script so it can point `_json` at the dexes it
 * deploys here instead of the committed addresses, and hand `_config` a config
 * of its own where the shipped one is not the subject.
 */
contract PoolScriptTest is Test, PoolScript {
    address internal constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant _BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
    address internal constant _AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
    address internal constant _RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    address internal constant _USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant _DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant _USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant _FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;

    bytes32 internal constant _BAL_WETH_POOL = 0x5c6ee304399dbdb9c8ef030ab642b10820db8f56000200000000000000000014;
    bytes32 internal constant _WETH_AURA_POOL = 0xcfca23ca9ca720b6e98e3eb9b6aa0ffc4a5c08b9000200000000000000000274;
    bytes32 internal constant _RETH_WETH_POOL = 0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112;

    address internal constant _THREE_POOL = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address internal constant _FRAX_POOL = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;

    BalancerDex internal _balancerDex;
    CurveDex internal _curveDex;

    function setUp() public {
        vm.setEnv("NETWORK", "test");
        _balancerDex = new BalancerDex();
        _curveDex = new CurveDex();
        _useDexes(address(_balancerDex), address(_curveDex));
    }

    /**
     * @notice The shipped config lands on the dexes it names
     */
    function testShippedConfig() public {
        vm.setEnv("SETUP_FILE", "Pools.0000.json");
        _config = vm.readFile(string.concat(vm.projectRoot(), "/script/config/Pools.0000.json"));
        this.deploy();

        assertEq(_balancerDex.pool(_WETH, _BAL), _BAL_WETH_POOL, "WETH/BAL");
        assertEq(_balancerDex.pool(_WETH, _AURA), _WETH_AURA_POOL, "WETH/AURA");
        // the two hops of BAL -> WETH -> rETH, each against its own pair
        assertEq(_balancerDex.pool(_BAL, _WETH), _BAL_WETH_POOL, "BAL/WETH");
        assertEq(_balancerDex.pool(_WETH, _RETH), _RETH_WETH_POOL, "WETH/rETH");

        assertEq(_curveDex.pool(_USDC, _DAI), _THREE_POOL, "USDC/DAI pool");
        assertEq(_curveDex.pool(_DAI, _USDT), _THREE_POOL, "DAI/USDT pool");
        assertEq(_curveDex.pool(_USDT, _FRAX), _FRAX_POOL, "USDT/FRAX pool");
        assertEq(_curveDex.pool(_USDC, _USDT), _THREE_POOL, "USDC/USDT pool");

        // [i, j, swap_type, pool_type, n_coins], with i and j the pool's coin
        // indices for the hop: 3pool holds DAI, USDC, USDT in that order, and
        // USDT reaches FRAX as an underlying of the FRAX/3CRV metapool.
        _assertParams(_USDC, _DAI, [uint256(1), 0, 1, 1, 3], "USDC/DAI params");
        _assertParams(_DAI, _USDT, [uint256(0), 2, 1, 1, 3], "DAI/USDT params");
        _assertParams(_USDT, _FRAX, [uint256(3), 0, 2, 1, 4], "USDT/FRAX params");
        _assertParams(_USDC, _USDT, [uint256(1), 2, 1, 1, 3], "USDC/USDT params");
    }

    /**
     * @notice A setter the dex rejects takes the run down with it
     */
    function testRevertsWhenTheDexRejectsTheCall() public {
        vm.prank(address(0xBEEF));
        _useDexes(address(new BalancerDex()), address(_curveDex));
        _config = _balancerEntry(_hop(_WETH, _BAL), _ids(_BAL_WETH_POOL));

        vm.expectRevert("Ownable: caller is not the owner");
        this.deploy();
    }

    /**
     * @notice A route with more pools than hops is refused before anything is sent
     */
    function testRevertsOnPoolCountMismatch() public {
        bytes32[] memory pools = new bytes32[](2);
        pools[0] = _BAL_WETH_POOL;
        pools[1] = _RETH_WETH_POOL;
        _config = _balancerEntry(_hop(_BAL, _RETH), pools);

        vm.expectRevert("BAL -> rETH: one pool per hop");
        this.deploy();
    }

    /**
     * @notice A path that does not run between the entry's own tokens is refused
     */
    function testRevertsOnPathThatSkipsTheBuyToken() public {
        address[] memory path = _hop(_BAL, _WETH);
        _config = string.concat(
            "[{",
            _field("buyToken", vm.toString(_RETH)),
            ",",
            _field("description", "BAL -> rETH"),
            ",",
            _field("dexName", "BalancerDex"),
            ',"params":[],"path":',
            _list(path),
            ',"pools":',
            _list(_ids(_BAL_WETH_POOL)),
            ",",
            _field("sellToken", vm.toString(_BAL)),
            "}]"
        );

        vm.expectRevert("BAL -> rETH: path does not end at buyToken");
        this.deploy();
    }

    /**
     * @notice A curve hop without its five router params is refused
     */
    function testRevertsOnShortCurveParams() public {
        _config = string.concat(
            "[{",
            _field("buyToken", vm.toString(_DAI)),
            ",",
            _field("description", "USDC -> DAI"),
            ",",
            _field("dexName", "CurveDex"),
            ',"params":[[1,0,1,1]],"path":',
            _list(_hop(_USDC, _DAI)),
            ',"pools":["',
            vm.toString(_THREE_POOL),
            '"],',
            _field("sellToken", vm.toString(_USDC)),
            "}]"
        );

        vm.expectRevert("USDC -> DAI: params must hold 5 values per hop");
        this.deploy();
    }

    /**
     * @notice A dex the script has no setter for is refused rather than skipped,
     * before it even looks the dex up in deployed-addresses.json
     */
    function testRevertsOnUnsupportedDex() public {
        _config = string.concat(
            "[{",
            _field("buyToken", vm.toString(_BAL)),
            ",",
            _field("description", "WETH -> BAL"),
            ",",
            _field("dexName", "SushiswapDex"),
            ',"params":[],"path":',
            _list(_hop(_WETH, _BAL)),
            ',"pools":',
            _list(_ids(_BAL_WETH_POOL)),
            ",",
            _field("sellToken", vm.toString(_WETH)),
            "}]"
        );

        vm.expectRevert("Pool.s.sol cannot configure pools on SushiswapDex");
        this.deploy();
    }

    function _assertParams(address _token0, address _token1, uint256[5] memory _expected, string memory _err) internal {
        uint256[5] memory got = _curveDex.params(_token0, _token1);
        for (uint256 i; i < 5;) {
            assertEq(got[i], _expected[i], _err);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev stands in for script/deployed-addresses.json, under the NETWORK key set above
    function _useDexes(address _balancer, address _curve) internal {
        _balancerDex = BalancerDex(payable(_balancer));
        _curveDex = CurveDex(payable(_curve));
        _json = string.concat(
            '{"test":{"BalancerDex":{"address":"',
            vm.toString(_balancer),
            '"},"CurveDex":{"address":"',
            vm.toString(_curve),
            '"}}}'
        );
    }

    function _balancerEntry(address[] memory _path, bytes32[] memory _pools) internal pure returns (string memory) {
        return string.concat(
            "[{",
            _field("buyToken", vm.toString(_path[_path.length - 1])),
            ",",
            _field("description", string.concat(_symbol(_path[0]), " -> ", _symbol(_path[_path.length - 1]))),
            ",",
            _field("dexName", "BalancerDex"),
            ',"params":[],"path":',
            _list(_path),
            ',"pools":',
            _list(_pools),
            ",",
            _field("sellToken", vm.toString(_path[0])),
            "}]"
        );
    }

    function _field(string memory _key, string memory _value) internal pure returns (string memory) {
        return string.concat('"', _key, '":"', _value, '"');
    }

    function _list(address[] memory _items) internal pure returns (string memory) {
        string memory out = "[";
        for (uint256 i; i < _items.length;) {
            out = string.concat(out, i == 0 ? '"' : ',"', vm.toString(_items[i]), '"');
            unchecked {
                ++i;
            }
        }
        return string.concat(out, "]");
    }

    function _list(bytes32[] memory _items) internal pure returns (string memory) {
        string memory out = "[";
        for (uint256 i; i < _items.length;) {
            out = string.concat(out, i == 0 ? '"' : ',"', vm.toString(_items[i]), '"');
            unchecked {
                ++i;
            }
        }
        return string.concat(out, "]");
    }

    function _hop(address _from, address _to) internal pure returns (address[] memory path) {
        path = new address[](2);
        path[0] = _from;
        path[1] = _to;
    }

    function _ids(bytes32 _id) internal pure returns (bytes32[] memory ids) {
        ids = new bytes32[](1);
        ids[0] = _id;
    }

    function _symbol(address _token) internal pure returns (string memory) {
        if (_token == _WETH) return "WETH";
        if (_token == _BAL) return "BAL";
        if (_token == _RETH) return "rETH";
        return "token";
    }
}
