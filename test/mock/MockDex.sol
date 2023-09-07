// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "../../src/core/dexes/BasicDex.sol";

// interfaces
import "../../src/interfaces/ILiquidityDex.sol";

contract MockDex is Ownable, BasicDex, ILiquidityDex {
    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] calldata _path)
        external
        override
        afterSwapCheck(_path[0], _path[_path.length - 1])
        returns (uint256 amountOut)
    {
        return 0;
    }

    function tokenWithdraw(address _token, uint256 _amount) public override onlyOwner {
        super.tokenWithdraw(_token, _amount);
    }
}
