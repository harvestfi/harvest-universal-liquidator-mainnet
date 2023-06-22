// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBancorNetwork {
    function rateByPath(address[] memory path, uint256 sourceAmount) external view returns (uint256);

    function conversionPath(address sourceToken, address targetToken) external view returns (address[] memory);

    function convertByPath(
        address[] memory path,
        uint256 sourceAmount,
        uint256 minReturn,
        address payable beneficiary,
        address affiliateAccount,
        uint256 affiliateFee
    ) external payable returns (uint256);
}
