// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "./BasicDex.sol";

// interfaces
import "../../interfaces/ILiquidityDex.sol";
import "../../interfaces/curve/ICurveRegistryExchange.sol";

// libraries
import "../../libraries/Addresses.sol";

// constants and types
import {CurveDexStorage} from "../storage/CurveDex.sol";

contract CurveDex is Ownable, BasicDex, ILiquidityDex, CurveDexStorage {
    using SafeERC20 for IERC20;

    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] calldata _path)
        external
        override
        returns (uint256 receiveAmt)
    {
        uint256 sellAmount = _sellAmount;
        uint256 minBuyAmount;
        address receiver;

        for (uint256 idx; idx < _path.length - 1;) {
            if (idx != _path.length - 2) {
                minBuyAmount = 1;
                receiver = address(this);
            } else {
                minBuyAmount = _minBuyAmount;
                receiver = _receiver;
            }

            address sellToken = _path[idx];
            address buyToken = _path[idx + 1];
            IERC20(sellToken).safeIncreaseAllowance(Addresses._CURVE_ROUTER, sellAmount);

            receiveAmt = ICurveRegistryExchange(Addresses._CURVE_ROUTER).exchange(
                _pool[sellToken][buyToken], sellToken, buyToken, sellAmount, minBuyAmount, receiver
            );

            sellAmount = IERC20(buyToken).balanceOf(address(this));
            unchecked {
                ++idx;
            }
        }
    }

    function setPool(address _token0, address _token1, address _poolAddr) external onlyOwner {
        _pool[_token0][_token1] = _poolAddr;
        _pool[_token1][_token0] = _poolAddr;
    }

    function pool(address _token0, address _token1) public view returns (address) {
        return _pool[_token0][_token1];
    }

    function tokenWithdraw(address _token, uint256 _amount) public override onlyOwner {
        super.tokenWithdraw(_token, _amount);
    }
}
