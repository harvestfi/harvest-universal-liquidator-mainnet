// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";

// interfaces
import "../../interfaces/ILiquidityDex.sol";
import "../../interfaces/bancor/IBancorNetwork.sol";
import "../../interfaces/bancor/IContractRegistry.sol";
import "../../interfaces/weth/IWeth9.sol";

// libraries
import "../../libraries/Addresses.sol";

// constants and types
import {BancorV2DexStorage} from "../storage/BancorV2Dex.sol";

contract BancorV2Dex is Ownable, ILiquidityDex, BancorV2DexStorage {
    using SafeERC20 for IERC20;

    // BancorDex's doSwap doesn't expect any address in the path to be bancorETH
    // they have to be regular tokens.
    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] memory _path)
        public
        override
        returns (uint256)
    {
        address sellToken = _path[0];
        address buyToken = _path[_path.length - 1];

        address finalTarget = _receiver;

        address network = getBancorNetworkContract();

        if (sellToken == Addresses._WETH) {
            WETH9(Addresses._WETH).withdraw(_sellAmount);
            sellToken = Addresses._BANCOR_ETH;
        } else {
            IERC20(sellToken).safeIncreaseAllowance(network, _sellAmount);
        }

        if (buyToken == Addresses._WETH) {
            buyToken = Addresses._BANCOR_ETH;
            // we will be receiving eth here, and wrap it back to WETH
            _receiver = address(this);
        }

        address[] memory actualPath = IBancorNetwork(network).conversionPath(sellToken, buyToken);

        uint256 outTokenReturned = IBancorNetwork(network).convertByPath{
            value: sellToken == Addresses._BANCOR_ETH ? _sellAmount : 0
        }(actualPath, _sellAmount, _minBuyAmount, payable(_receiver), _affiliateAccount, _affiliateFee);

        // If buyToken is bancorEth, then this contract has received ETH after the swap.
        // ETH should be wrapped back to WETH
        if (buyToken == Addresses._BANCOR_ETH) {
            uint256 ethBalance = address(this).balance;
            WETH9(Addresses._WETH).deposit{value: ethBalance}();
            outTokenReturned = IERC20(Addresses._WETH).balanceOf(address(this));
            IERC20(Addresses._WETH).safeTransfer(finalTarget, outTokenReturned);
        }

        return outTokenReturned;
    }

    function configure(address _newAffiliateAccount, uint256 _newAffiliateFee) external onlyOwner {
        _affiliateAccount = _newAffiliateAccount;
        _affiliateFee = _newAffiliateFee;
    }

    function getBancorNetworkContract() public view returns (address) {
        return IContractRegistry(Addresses._BANCOR_REGISTRY).addressOf(bytes32("BancorNetwork"));
    }

    function affiliateAccount() external view returns (address) {
        return _affiliateAccount;
    }

    function affiliateFee() external view returns (uint256) {
        return _affiliateFee;
    }

    receive() external payable {}
}