// Load dependencies
const { Web3Provider } = require('@ethersproject/providers');
const { expect } = require('chai');
const chai = require("chai");
chai.use(require("chai-events"));
const should = chai.should();
const EventEmitter = require("events");

//prepare example accounts for localhost blockchain testing
const player1public = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
const player2public = '0x70997970c51812dc3a010c7d01b50e0d17dc79c8';
const player1priv = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
const player2priv = '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';


describe("GameFactory contract", function () {

  let emitter = null;

  before(async function () {
    this.GameFactory = await ethers.getContractFactory('GameFactory');
  });

  beforeEach(async function () {
    this.gameFactory = await this.GameFactory.deploy();
    await this.gameFactory.deployed();
    emitter = new EventEmitter();
  });

  it("Should return gameFee value equals 1 ether", async function () {
    expect(await this.gameFactory.getGameFee()==1);
  
  });

  it("Should change gameFee value to 2 ether", async function () {
    
    expect(await this.gameFactory.setGameFee(2));
    expect(await this.gameFactory.getGameFee()==2);

  });

  it("Should get actual games count", async function () {
    
    expect(await this.gameFactory.getGamesCount());

  });

  it("Should get actual game counter state", async function () {
    
    expect(await this.gameFactory.getGameCreationCounter());

  });

  it("Should create a new Game instance with player1 as host, Rock figure and 40000 wei as initial stake", async function () {
    
    expect(x = await this.gameFactory.createGame(player1public,1,40000));

  });

  it("Should catch a emitted event during a new Game creation", async function () {
    
    expect(await this.gameFactory.createGame(player2public,1,40000));


  });

  it("Should create a new game as player1 and join it as player2", async function () {
    
    expect(await this.gameFactory.joinGame(gameId,1,60000));

  });

  it("Should generate a new gameId", async function () {
    
    expect(await this.gameFactory.generateId());

  });

  it("Should display all game Ids", async function () {
    
    expect(x = await this.gameFactory.getGamesList());

  });

  it("Should display all active games count", async function () {
    
    expect(x = await this.gameFactory.getGamesCount());

  });
  
  
});
