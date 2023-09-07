// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "../../src/core/dexes/BasicDex.sol";

// interfaces
import "../../src/interfaces/ILiquidityDex.sol";

contract MockDex is Ownable, BasicDex {
    function tokenWithdraw(address _token, uint256 _amount) public override onlyOwner {
        super.tokenWithdraw(_token, _amount);
    }
}
