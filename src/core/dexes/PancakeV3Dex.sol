// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "./BasicDex.sol";

// interfaces
import "../../interfaces/ILiquidityDex.sol";
import "../../interfaces/uniswap/ISwapRouter.sol";

// libraries
import "../../libraries/Addresses.sol";

// constants and types
import {PancakeV3DexStorage} from "../storage/PancakeV3Dex.sol";

contract PancakeV3Dex is Ownable, BasicDex, ILiquidityDex, PancakeV3DexStorage {
    using SafeERC20 for IERC20;

    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] calldata _path)
        external
        override
        returns (uint256)
    {
        address sellToken = _path[0];

        IERC20(sellToken).safeIncreaseAllowance(Addresses._PANCAKEV3_ROUTER, _sellAmount);

        bytes memory encodedPath = abi.encodePacked(sellToken);
        for (uint256 idx = 1; idx < _path.length;) {
            encodedPath = abi.encodePacked(encodedPath, pairFee(_path[idx - 1], _path[idx]), _path[idx]);
            unchecked {
                ++idx;
            }
        }

        ISwapRouter.ExactInputParams memory param = ISwapRouter.ExactInputParams({
            path: encodedPath,
            recipient: _receiver,
            deadline: block.timestamp,
            amountIn: _sellAmount,
            amountOutMinimum: _minBuyAmount
        });

        return ISwapRouter(Addresses._PANCAKEV3_ROUTER).exactInput(param);
    }

    function pairFee(address _sellToken, address _buyToken) public view returns (uint24 fee) {
        if (_pairFee[_sellToken][_buyToken] != 0) {
            return _pairFee[_sellToken][_buyToken];
        } else {
            return 500;
        }
    }

    function setFee(address _token0, address _token1, uint24 _fee) external onlyOwner {
        _pairFee[_token0][_token1] = _fee;
        _pairFee[_token1][_token0] = _fee;
    }

    function tokenWithdraw(address _token, uint256 _amount) public override onlyOwner {
        super.tokenWithdraw(_token, _amount);
    }
}
