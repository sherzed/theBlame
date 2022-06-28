const { expect } = require("chai");
const { Wallet } = require("ethers");
const { ethers } = require("hardhat");

require("@nomiclabs/hardhat-waffle");
import("REPO/blame.sol");
describe("theBlame", function () {
  let contract;
  let owner;

  beforeEach(async function () {
    const theBlame = await ethers.getContractFactory("theBlame");
    const bixos = await theBlame.deploy("Life's Good");
    contract = await bixos.deployed();
    [owner] = await ethers.getSigners();
  });
  it("Trying commands via 'createBlame' function", async function () {
    const test = expect(await contract.createBlame("Anonymous", "Life's Good"));
  });
  it("Trying commands via 'deleteBlame' function", async function () {
    const test = expect(await contract.deleteBlame(0)); // 0 = Blame ID
  });
  it("Trying commands via 'boostBlame' function", async function () {
    const test = expect(await contract.boostBlame(0)); // 0 = Blame ID
  });
  it("Trying commands via 'witdhdrawEarnings' function", async function () {
    const test = expect(await contract.witdhdrawEarnings());
  });
  it("Trying commands via 'claimBlame' function", async function () {
    const test = expect(await contract.claimBlame());
  });
});
