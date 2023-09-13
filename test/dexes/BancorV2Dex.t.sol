// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// libraries
import "../../src/core/dexes/BancorV2Dex.sol";

// import test base and helpers.
import {AdvancedFixture} from "../AdvancedFixture.sol";

contract BancorV2DexTest is AdvancedFixture {
    function testSetPoolFee() public {
        // deploy dex
        startHoax(_governance);
        _bancorV2Dex = new BancorV2Dex();
        _bancorV2Dex.configure(_governance, 3000);
        uint256 affiliateFee = _bancorV2Dex.affiliateFee();
        address affiliateAccount = _bancorV2Dex.affiliateAccount();
        assertEq(affiliateFee, 3000);
        assertEq(affiliateAccount, _governance);
        vm.stopPrank();
    }

    function testCannotSetPoolFeeFromNonOwner() public {
        // deploy dex
        vm.prank(_governance);
        _bancorV2Dex = new BancorV2Dex();
        vm.expectRevert("Ownable: caller is not the owner");
        _bancorV2Dex.configure(_governance, 3000);
        vm.prank(_governance);
        _bancorV2Dex.configure(_governance, 3000);
        uint256 affiliateFee = _bancorV2Dex.affiliateFee();
        address affiliateAccount = _bancorV2Dex.affiliateAccount();
        assertEq(affiliateFee, 3000);
        assertEq(affiliateAccount, _governance);
    }
}
