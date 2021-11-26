// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IRandomNumberGenerator.sol";
import "./interfaces/IWagyuSwapLottery.sol";

contract RandomNumberGenerator is IRandomNumberGenerator, Ownable {
    using SafeERC20 for IERC20;

    address public wagyuSwapLottery;
    uint32 public randomResult;
    uint256 public latestLotteryId;
    uint256 public seed;

    mapping(address => bool) public isTruster;

    function asciiToInteger(bytes32 x) public pure returns (uint256) {
        uint256 y;
        for (uint256 i = 0; i < 32; i++) {
            uint256 c = (uint256(x) >> (i * 8)) & 0xff;
            if (48 <= c && c <= 57) y += (c - 48) * 10**i;
            else break;
        }
        return y;
    }

    /**
     * @notice Request randomness from a user-provided seed
     * @param _seed: seed provided by the PancakeSwap lottery
     */
    function getRandomNumber(uint256 _seed) external override {
        seed = _seed;
    }

    function setTruster(address addr, bool trust) external onlyOwner {
        require(addr != address(0), "Invalid");
        isTruster[addr] = trust;
    }

    /**
     * @notice Set the address for the PancakeSwapLottery
     * @param _wagyuSwapLottery: address of the PancakeSwap lottery
     */
    function setLotteryAddress(address _wagyuSwapLottery) external onlyOwner {
        wagyuSwapLottery = _wagyuSwapLottery;
    }

    /**
     * @notice View latestLotteryId
     */
    function viewLatestLotteryId() external view override returns (uint256) {
        return latestLotteryId;
    }

    /**
     * @notice View random result
     */
    function viewRandomResult() external view override returns (uint32) {
        return randomResult;
    }

    /**
     * @notice Callback function used by ChainLink's VRF Coordinator
     */
    function fulfillRandomness() external {
        require(isTruster[msg.sender], "Not truster");

        uint256 random = (seed % 1000000) * (asciiToInteger(blockhash(block.number)) % 1000000);
        randomResult = uint32(1000000 + (random % 1000000));
        latestLotteryId = IWagyuSwapLottery(wagyuSwapLottery).viewCurrentLotteryId();
    }
}
