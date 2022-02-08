const { expect } = require("chai");

describe("GameToken contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners();

    const GameToken = await ethers.getContractFactory("GameToken");

    const gameToken = await GameToken.deploy("Game Token", "GT");

    const ownerBalance = await gameToken.balanceOf(owner.address);
    expect(await gameToken.totalSupply()).to.equal(ownerBalance);
  });
});
