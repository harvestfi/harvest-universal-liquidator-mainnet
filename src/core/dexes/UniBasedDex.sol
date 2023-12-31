// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "./BasicDex.sol";

// interfaces
import "../../interfaces/ILiquidityDex.sol";
import "../../interfaces/uniswap/v2/IUniswapV2Router02.sol";
import "../../interfaces/uniswap/v2/IUniswapV2Factory.sol";

// constants and types
import {BaseDexStorage} from "../storage/BaseDex.sol";

contract UniBasedDex is Ownable, BasicDex, ILiquidityDex, BaseDexStorage {
    using SafeERC20 for IERC20;

    constructor(address _initRouter) {
        _router = _initRouter;
    }

    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] calldata _path)
        external
        override
        afterSwapCheck(_path[0], _path[_path.length - 1])
        returns (uint256)
    {
        address sellToken = _path[0];

        IERC20(sellToken).safeIncreaseAllowance(_router, _sellAmount);

        uint256[] memory returned =
            IUniswapV2Router02(_router).swapExactTokensForTokens(_sellAmount, _minBuyAmount, _path, _receiver, block.timestamp);

        return returned[returned.length - 1];
    }

    function router() public view returns (address) {
        return _router;
    }

    function tokenWithdraw(address _token, uint256 _amount) public override onlyOwner {
        super.tokenWithdraw(_token, _amount);
    }
}
