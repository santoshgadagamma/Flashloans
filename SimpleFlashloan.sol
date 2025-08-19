// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider, IPool} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AaveV3FlashloanBot is FlashLoanSimpleReceiverBase {
    event ArbitrageExecuted(address indexed executor, uint256 profit);

    constructor(IPoolAddressesProvider provider) FlashLoanSimpleReceiverBase(provider) {}

    function startFlashloan(address asset, uint256 amount, bytes calldata params) external {
        POOL.flashLoanSimple(address(this), asset, amount, params, 0);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address , // initiator
        bytes calldata
    ) external override returns (bool) {
        // Custom arbitrage logic here
        uint256 totalOwed = amount + premium;
        IERC20(asset).approve(address(POOL), totalOwed);
        emit ArbitrageExecuted(msg.sender, IERC20(asset).balanceOf(address(this)) - totalOwed);
        return true;
    }
}
