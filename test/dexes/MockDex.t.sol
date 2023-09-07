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
        (, bytes memory data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", testWhale));
        uint256 balance = abi.decode(data, (uint256));
        (, data) = testToken.call(abi.encodeWithSignature("transfer(address,uint256)", address(mockDex), balance));
        (, data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", address(mockDex)));
        assertEq(balance, abi.decode(data, (uint256)));
        changePrank(_governance);
        mockDex.tokenWithdraw(testToken, balance);
        (, data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", _governance));
        assertEq(balance, abi.decode(data, (uint256)));
    }

    function testWithdrawTokenFailNotOwner() public {
        address testToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT
        address testWhale = 0x276cdBa3a39aBF9cEdBa0F1948312c0681E6D5Fd;
        changePrank(testWhale);
        (, bytes memory data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", testWhale));
        uint256 balance = abi.decode(data, (uint256));
        (, data) = testToken.call(abi.encodeWithSignature("transfer(address,uint256)", address(mockDex), balance));
        (, data) = testToken.call(abi.encodeWithSignature("balanceOf(address)", address(mockDex)));
        assertEq(balance, abi.decode(data, (uint256)));
        vm.expectRevert("Ownable: caller is not the owner");
        mockDex.tokenWithdraw(testToken, balance);
    }

    function testAfterSwapBalance() public {
        address testToken1 = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT
        address testWhale = 0x276cdBa3a39aBF9cEdBa0F1948312c0681E6D5Fd;
        changePrank(testWhale);
        (, bytes memory data) = testToken1.call(abi.encodeWithSignature("balanceOf(address)", testWhale));
        uint256 balance1 = abi.decode(data, (uint256));
        (, data) = testToken1.call(abi.encodeWithSignature("transfer(address,uint256)", address(mockDex), balance1));

        address testToken2 = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; //USDC
        testWhale = 0x5dBdeb65668075f42AA9eF8202Ee2B07A14EaF43;
        changePrank(testWhale);
        (, data) = testToken2.call(abi.encodeWithSignature("balanceOf(address)", testWhale));
        uint256 balance2 = abi.decode(data, (uint256));
        (, data) = testToken2.call(abi.encodeWithSignature("transfer(address,uint256)", address(mockDex), balance2));

        address[] memory path = new address[](2);
        path[0] = testToken1;
        path[1] = testToken2;

        changePrank(_governance);
        // should fail if sell token balance > 0
        vm.expectRevert();
        mockDex.doSwap(0, 0, address(0), path);
        mockDex.tokenWithdraw(testToken1, balance1);
        // should fail if buy token balance > 0
        vm.expectRevert();
        mockDex.doSwap(0, 0, address(0), path);
        mockDex.tokenWithdraw(testToken2, balance2);
        // should success
        mockDex.doSwap(0, 0, address(0), path);
    }
}
