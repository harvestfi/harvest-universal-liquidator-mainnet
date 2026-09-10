// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

abstract contract EnvVariables is Test {
    // CI supplies ALCHEMEY_KEY, which is what the fork used to be built from.
    // RPC_URL overrides it; with neither, a public endpoint keeps a bare
    // checkout working, at the mercy of its rate limit.
    string internal _RPC_URL = _forkUrl();
    address internal _governance = 0xF066789028fE31D4f53B69B81b328B8218Cc0641;

    function _forkUrl() private returns (string memory) {
        string memory url = vm.envOr("RPC_URL", string(""));
        if (bytes(url).length != 0) return url;
        string memory key = vm.envOr("ALCHEMEY_KEY", string(""));
        if (bytes(key).length != 0) return string.concat("https://eth-mainnet.g.alchemy.com/v2/", key);
        return "https://eth.drpc.org";
    }
}
