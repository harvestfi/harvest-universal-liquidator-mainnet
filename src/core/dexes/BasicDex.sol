// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract BasicDex {
    function tokenWithdraw(address _token, uint256 _amount) public virtual {
        (bool success,) = _token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _amount));
        require(success, "BasicDex: transfer failed");
    }

    receive() external payable {}
}
