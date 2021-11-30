import { Contract, ContractFactory } from "ethers";
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import config from "./config.json";
import { waitSeconds } from "./utils";

async function main(): Promise<void> {
  // Hardhat always runs the compile task when running scripts through it.
  // If this runs in a standalone fashion you may want to call compile manually
  // to make sure everything is compiled
  // await run("compile");

  // We get the contract to deploy
  const params = config.velas;

  // construction params

  const RandomNumberGenerator: ContractFactory = await ethers.getContractFactory("RandomNumberGenerator");
  const randomNumberGenerator: Contract = await RandomNumberGenerator.deploy();
  await randomNumberGenerator.deployed();

  console.log("RandomNumberGenerator deployed to:", randomNumberGenerator.address);

  await randomNumberGenerator.setTruster(params.randomTruster, true);

  console.log("Random truster is set to", params.randomTruster);

  await waitSeconds(10);

  const WagyuSwapLottery: ContractFactory = await ethers.getContractFactory("WagyuSwapLottery");
  const wagyuSwapLottery: Contract = await WagyuSwapLottery.deploy(params.wag, randomNumberGenerator.address);
  await wagyuSwapLottery.deployed();

  console.log("WagyuSwapLottery deployed to:", wagyuSwapLottery.address);

  await randomNumberGenerator.setLotteryAddress(wagyuSwapLottery.address);

  await wagyuSwapLottery.setOperatorAndTreasuryAndInjectorAddresses(params.operator, params.treasury, params.injector);
  console.log("WagyuSwapLottery operator is set to", params.operator);
  console.log("WagyuSwapLottery treasury is set to", params.treasury);
  console.log("WagyuSwapLottery injector is set to", params.injector);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
