// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// import contracts and libraries
import "../mock/MockDex.sol";

// import test base and helpers.
import {console2, AdvancedFixture} from "../AdvancedFixture.sol";

contract MockDexTest is AdvancedFixture {
    MockDex public mockDex;

    function setUp() public {
        vm.startPrank(_governance);
        mockDex = new MockDex();
    }

    function testWithdrawToken() public {
        address testToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT
        address testWhale = 0x276cdBa3a39aBF9cEdBa0F1948312c0681E6D5Fd;
        changePrank(testWhale);
        (bool success, bytes memory data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", testWhale));
        assertTrue(success);
        uint256 balance = abi.decode(data, (uint256));
        (success, data) = testToken.call(abi.encodeWithSignature("transfer(address,uint256)", address(mockDex), balance));
        (success, data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", address(mockDex)));
        assertEq(balance, abi.decode(data, (uint256)));
        changePrank(_governance);
        mockDex.tokenWithdraw(testToken, balance);
        (success, data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", _governance));
        assertEq(balance, abi.decode(data, (uint256)));
    }

    function testWithdrawTokenFailNotOwner() public {
        address testToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT
        address testWhale = 0x276cdBa3a39aBF9cEdBa0F1948312c0681E6D5Fd;
        changePrank(testWhale);
        (bool success, bytes memory data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", testWhale));
        assertTrue(success);
        uint256 balance = abi.decode(data, (uint256));
        (success, data) = testToken.call(abi.encodeWithSignature("transfer(address,uint256)", address(mockDex), balance));
        (success, data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", address(mockDex)));
        assertEq(balance, abi.decode(data, (uint256)));
        vm.expectRevert("Ownable: caller is not the owner");
        mockDex.tokenWithdraw(testToken, balance);
    }
}
