//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GameFactory is Ownable {

    enum figure {UNDECLARED,ROCK,PAPER,SCISSORS,FIGURES_COUNT}
    enum gameScore {UNDECLARED,WIN,LOSE,DRAW}
    
    uint256 private gameCreationCounter;
    uint256 private gamesCount;
    uint private gameFee = 1000 wei;

    mapping(bytes32 => Game) private gameTable;
    bytes32[] private gameIds;

    event LogGameId(bytes32 gameId);
    event betOutput(bool);

    modifier isCurrentPlayerNotHost(bytes32 _id){
        require(msg.sender!=gameTable[_id].host, 'You cannot join your own game!');
        _;
    }

    modifier gameExist(bytes32 _id){
        require(msg.sender!=gameTable[_id].host, 'Game does not exist.');
        _;
    }
    
    modifier figureExist(uint _figure){
        require(_figure >= 1 && _figure <= uint(figure.FIGURES_COUNT), 'There is no figure coresponding to this number');
        _;
    }

    struct Game {
        address payable host;
        address payable guest;
        uint8 hostFigure;
        uint8 guestFigure;
        uint8 score;
        uint stake;
    }

    function createGame(address payable host,uint8 hostFigure, uint initialStake) public figureExist(hostFigure) {
        require(address(msg.sender).balance>=gameFee+initialStake,'Not enought ETH to create a game!');
        gameCreationCounter++;
        bytes32 gameId = generateId();
        gameTable[gameId] = Game(host,payable(address(0)),hostFigure,0,0,initialStake);
        gameIds.push(gameId);
        gamesCount++;
        emit LogGameId(gameId);
    }

    function generateId() view public returns (bytes32) {
        return keccak256(abi.encodePacked(msg.sender,block.timestamp,gameCreationCounter));
    }

    function joinAndPlayGame(bytes32 _id, uint8 _guestFigure, uint _stake) public isCurrentPlayerNotHost(_id) figureExist(_guestFigure) gameExist(_id) {
        require(address(msg.sender).balance>=gameFee+_stake,'Not enought ETH to play a game!');
        gameScore currentGameScore;
        uint sumamrizedStake = gameTable[_id].stake+_stake;
        gameTable[_id].guest = payable(msg.sender);
        gameTable[_id].guestFigure = uint8(_guestFigure);
        currentGameScore = returnGameScore(gameTable[_id].hostFigure,_guestFigure);
        gameTable[_id].score = uint8(currentGameScore);
        
        if(currentGameScore==gameScore.WIN) {
            sendStakeToWinner(gameTable[_id].host,sumamrizedStake);
        } else if(currentGameScore==gameScore.LOSE) {
            sendStakeToWinner(gameTable[_id].guest,sumamrizedStake);
        } else {
            gameTable[_id].stake = sumamrizedStake;
        }

    }

    function deleteGame(bytes32 _id) public gameExist(_id) {
        require(msg.sender==gameTable[_id].host,'Only game host is allowed to detele game.');
        address payable _gameOwner = gameTable[_id].host;
        _gameOwner.transfer(gameTable[_id].stake);
        delete gameTable[_id];
        gamesCount = gamesCount--;
    }

    function sendStakeToWinner(address payable stakeReceiver, uint stake) public payable {
         stakeReceiver.transfer(stake);
    }

    function setGameFee(uint _fee) external onlyOwner {
        gameFee = _fee;
    }

    function getGameFee() public onlyOwner view returns (uint) {
        return gameFee;
    }

    function getGameCreationCounter() public onlyOwner view returns (uint) {
        return gameCreationCounter;
    }

    function getGamesCount() public onlyOwner view returns (uint) {
        return gameIds.length;
    }

    function getGamesList() public onlyOwner view returns (bytes32[] memory) {
        return gameIds;
    }

    function getGameInfo(bytes32 _gameId) public onlyOwner view returns (Game memory) {
        return gameTable[_gameId];
    }

    function betPreviousScore(bytes32 _gameId, uint _score, uint _stake) public gameExist(_gameId) {

        if (gameTable[_gameId].score==_score) { 
            sendStakeToWinner(payable(address(this)), _stake);
            emit betOutput(true);
        } else {
            sendStakeToWinner(payable(msg.sender), _stake);
            emit betOutput(false);
        }
    }


    function returnGameScore(uint8 _hostFigure, uint8 _guestFigure) pure public returns (gameScore) {
              if((_hostFigure == uint8(figure.ROCK) && _guestFigure == uint8(figure.SCISSORS)) ||
                (_hostFigure == uint8(figure.SCISSORS) && _guestFigure == uint8(figure.PAPER)) ||
                (_hostFigure == uint8(figure.PAPER) && _guestFigure == uint8(figure.ROCK))) {
                return gameScore.WIN;
                } else if (_hostFigure == _guestFigure) {
                return gameScore.DRAW;
                } else return gameScore.LOSE;
    }
}
