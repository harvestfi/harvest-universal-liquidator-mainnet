// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "./BasicDex.sol";

// interfaces
import "../../interfaces/ILiquidityDex.sol";
import "../../interfaces/aave/IAToken.sol";
import "../../interfaces/aave/IPool.sol";

contract AaveDex is Ownable, BasicDex, ILiquidityDex {
    using SafeERC20 for IERC20;

    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] memory _path)
        external
        override
        afterSwapCheck(_path[0], _path[_path.length - 1])
        returns (uint256)
    {
        require(_path.length == 2, "Path length needs to be 2");
        address sellToken = _path[0];
        address buyToken = _path[1];

        if (isAToken(sellToken)) {
            require(checkUnderlying(sellToken, buyToken), "Underlying mismatch");
            address _pool = IAToken(sellToken).POOL();
            IPool(_pool).withdraw(sellToken, _sellAmount, address(this));
        } else if (isAToken(buyToken)) {
            require(checkUnderlying(buyToken, sellToken), "Underlying mismatch");
            address _pool = IAToken(buyToken).POOL();
            IERC20(sellToken).safeIncreaseAllowance(_pool, _sellAmount);
            IPool(_pool).supply(buyToken, _sellAmount, address(this), 0);
        } else {
            revert("No Aave Token");
        }

        uint256 output = IERC20(buyToken).balanceOf(address(this));
        require(output >= _minBuyAmount, "Too little received");
        IERC20(buyToken).safeTransfer(_receiver, output);
        return output;
    }

    function isAToken(address token) internal view returns (bool) {
        try IAToken(token).UNDERLYING_ASSET_ADDRESS() returns (address underlying) {
            if (underlying != address(0)) {
                return true;
            } else {
                return false;
            }
        } catch {
            return false;
        }
    }

    function checkUnderlying(address token, address underlying) internal view returns (bool) {
        return (IAToken(token).UNDERLYING_ASSET_ADDRESS() == underlying);
    }
}
