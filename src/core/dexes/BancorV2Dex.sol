// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "./BasicDex.sol";

// interfaces
import "../../interfaces/ILiquidityDex.sol";
import "../../interfaces/bancor/IBancorNetwork.sol";
import "../../interfaces/bancor/IContractRegistry.sol";
import "../../interfaces/weth/IWeth9.sol";

// libraries
import "../../libraries/Addresses.sol";

// constants and types
import {BancorV2DexStorage} from "../storage/BancorV2Dex.sol";

contract BancorV2Dex is Ownable, BasicDex, ILiquidityDex, BancorV2DexStorage {
    using SafeERC20 for IERC20;

    // BancorDex's doSwap doesn't expect any address in the path to be bancorETH
    // they have to be regular tokens.
    function doSwap(uint256 _sellAmount, uint256 _minBuyAmount, address _receiver, address[] calldata _path)
        external
        override
        afterSwapCheck(_path[0], _path[_path.length - 1])
        returns (uint256 outTokenReturned)
    {
        uint256 sellAmount = _sellAmount;
        uint256 minBuyAmount = _minBuyAmount;
        address receiver = _receiver;

        address sellToken = _path[0];
        address buyToken = _path[_path.length - 1];
        address finalReceiver = _receiver;
        address network = getBancorNetworkContract();

        if (sellToken == Addresses._WETH) {
            WETH9(Addresses._WETH).withdraw(sellAmount);
            sellToken = Addresses._BANCOR_ETH;
        } else {
            IERC20(sellToken).safeIncreaseAllowance(network, sellAmount);
        }

        if (buyToken == Addresses._WETH) {
            // we will be receiving eth here, and wrap it back to WETH
            buyToken = Addresses._BANCOR_ETH;
            receiver = address(this);
        }

        address[] memory actualPath = IBancorNetwork(network).conversionPath(sellToken, buyToken);

        outTokenReturned = IBancorNetwork(network).convertByPath{value: sellToken == Addresses._BANCOR_ETH ? sellAmount : 0}(
            actualPath, sellAmount, minBuyAmount, payable(receiver), _affiliateAccount, _affiliateFee
        );

        // If buyToken is bancorEth, then this contract has received ETH after the swap.
        // ETH should be wrapped back to WETH
        if (buyToken == Addresses._BANCOR_ETH) {
            WETH9(Addresses._WETH).deposit{value: address(this).balance}();
            outTokenReturned = IERC20(Addresses._WETH).balanceOf(address(this));
            IERC20(Addresses._WETH).safeTransfer(finalReceiver, outTokenReturned);
        }

        //return outTokenReturned;
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

    function tokenWithdraw(address _token, uint256 _amount) public override onlyOwner {
        super.tokenWithdraw(_token, _amount);
    }
}
