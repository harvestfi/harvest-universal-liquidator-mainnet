// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "./BasicDex.sol";

// interfaces
import "../../interfaces/ILiquidityDex.sol";
import "../../interfaces/curve/ICurveRouter.sol";

// libraries
import "../../libraries/Addresses.sol";

// constants and types
import {CurveDexStorage} from "../storage/CurveDex.sol";

contract CurveDex is Ownable, BasicDex, ILiquidityDex, CurveDexStorage {
    using SafeERC20 for IERC20;

    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] memory _path)
        external
        override
        afterSwapCheck(_path[0], _path[_path.length - 1])
        returns (uint256)
    {
        IERC20(_path[0]).safeIncreaseAllowance(Addresses._CURVE_ROUTER, _sellAmount);

        address[11] memory curvePath;
        uint256[5][5] memory swapParams;
        address[5] memory pools;
        for (uint256 idx; idx < _path.length - 1;) {
            curvePath[idx * 2] = _path[idx];
            curvePath[idx * 2 + 1] = pool(_path[idx], _path[idx + 1]);
            swapParams[idx] = params(_path[idx], _path[idx + 1]);
            pools[idx] = pool(_path[idx], _path[idx + 1]);

            if (idx == _path.length - 2) {
                curvePath[idx * 2 + 2] = _path[idx + 1];
            }

            unchecked {
                ++idx;
            }
        }
        ICurveRouter(Addresses._CURVE_ROUTER).exchange(curvePath, swapParams, _sellAmount, _minBuyAmount, pools, _receiver);
    }

    function pairSetup(address _token0, address _token1, address _poolAddr, uint256[5] calldata __params) external onlyOwner {
        _pool[_token0][_token1] = _poolAddr;
        _params[_token0][_token1] = __params;
    }

    function pool(address _token0, address _token1) public view returns (address) {
        return _pool[_token0][_token1];
    }

    function params(address _token0, address _token1) public view returns (uint256[5] memory) {
        return _params[_token0][_token1];
    }
}
