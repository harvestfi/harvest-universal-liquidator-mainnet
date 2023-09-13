// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// imported contracts and libraries
import "openzeppelin/token/ERC20/IERC20.sol";

// libraries
import "../../libraries/Errors.sol";

abstract contract BasicDex {
    modifier afterSwapCheck(address _sellToken, address _buyToken) {
        _;

        if (IERC20(_sellToken).balanceOf(address(this)) > 0) {
            revert Errors.InvalidBalance(_sellToken);
        }
        if (IERC20(_buyToken).balanceOf(address(this)) > 0) {
            revert Errors.InvalidBalance(_buyToken);
        }
    }

    function tokenWithdraw(address _token, uint256 _amount) public virtual {
        (bool success,) = _token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _amount));
        require(success, "BasicDex: transfer failed");
    }

    receive() external payable {}
}
