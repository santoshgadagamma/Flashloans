// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashloanExecutor is IFlashLoanSimpleReceiver {
    IPool public immutable pool;

    constructor(address provider) {
        IPoolAddressesProvider _provider = IPoolAddressesProvider(provider);
        pool = IPool(_provider.getPool());
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        // Your logic here (e.g., arbitrage, swaps, liquidation)
        
        uint256 totalDebt = amount + premium;
        IERC20(asset).approve(address(pool), totalDebt);
        return true;
    }

    function initiateFlashloan(address asset, uint256 amount) external {
        bytes memory data = ""; // Custom parameters can be encoded here
        pool.flashLoanSimple(address(this), asset, amount, data, 0);
    }
}
