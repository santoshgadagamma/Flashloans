//Aave interface
interface IFlashLoanSimpleReceiver {
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

//Ipool interface
interface IPool {
    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

//IFlashLoanSimpleReceiver
function executeOperation(
    address asset,
    uint256 amount,
    uint256 premium,
    address initiator,
    bytes calldata params
) external override returns (bool);

//IERC20

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}
/**** Flashloan Code**/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPool} from "./interfaces/IPool.sol";
import {IFlashLoanSimpleReceiver} from "./interfaces/IFlashLoanSimpleReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashloanArbitrage is IFlashLoanSimpleReceiver {
    address public owner;
    address public immutable POOL;

    constructor(address _poolAddress) {
        owner = msg.sender;
        POOL = _poolAddress;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Initiate flashloan
    function startFlashLoan(address token, uint256 amount) external onlyOwner {
        bytes memory params = ""; // Optional custom data

        IPool(POOL).flashLoanSimple(
            address(this), // receiver
            token,         // token to borrow
            amount,        // amount
            params,        // any params to pass to executeOperation
            0              // referral code
        );
    }

    // Logic called by Aave during flashloan
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(msg.sender == POOL, "Caller is not Aave Pool");
        require(initiator == address(this), "Not initiated by contract");

        // TODO: Perform arbitrage logic here
        // Example: Call Uniswap to swap token -> another token -> back to token

        // Repay Aave
        uint256 totalRepayment = amount + premium;
        IERC20(asset).approve(POOL, totalRepayment);

        return true;
    }
}
