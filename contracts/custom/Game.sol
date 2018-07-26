pragma solidity ^0.4.24;

contract Game {
  
  uint8 constant DONT_TELL_ANYTHING = 8;
  uint8 constant TELL_EVERYTHING = 10;
  
  uint8 constant RESULT_TEN_ZERO = 1;
  uint8 constant RESULT_ZERO_TEN = 2;
  uint8 constant RESULT_TWO_TWO = 3;
  uint8 constant RESULT_HALF_HALF = 4;
  
  uint8 constant IN_PROGRESS = 1;
  uint8 constant DONE = 7;
  
  uint8 constant OPENED = 11;
  uint8 constant CLOSED = 12;
  
  address []currentPlayers;
  uint256 len;
  
  struct Stats {
    uint256 qOfGames;
    uint8 [9] results;
    uint8 [9] answer;
    address [9] partner;
    uint8 [9] gameStatus;
  }
  
  mapping(address => Stats) stats;
  
  function bet(uint8 _answer) returns (uint8 res) {
    require(stats[msg.sender].gameStatus[stats[msg.sender].qOfGames] != OPENED);
    stats[msg.sender].answer[stats[msg.sender].qOfGames] = _answer;
    stats[msg.sender].gameStatus[stats[msg.sender].qOfGames] = OPENED;
    res = play(msg.sender);
  }
  
  function play(address _player) returns (uint8) {
    
    currentPlayers.push(_player);
    len++;
    
    if (len % 2 != 0) {
      return IN_PROGRESS;
    }
    
    if (len % 2 == 0) {
      address pOne = currentPlayers[len - 2];
      address pTwo = currentPlayers[len - 1];
      uint8 _resOne = stats[pOne].answer[stats[pOne].qOfGames];
      uint8 _resTwo = stats[pTwo].answer[stats[pTwo].qOfGames];
      uint8 resultOfGame = calcResOfGame(_resOne, _resTwo);
      stats[pOne].results[stats[pOne].qOfGames] = resultOfGame;
      stats[pTwo].results[stats[pTwo].qOfGames] = resultOfGame;
      stats[pOne].partner[stats[pOne].qOfGames] = pTwo;
      stats[pTwo].partner[stats[pTwo].qOfGames] = pOne;
      stats[pOne].gameStatus[stats[pOne].qOfGames] = CLOSED;
      stats[pTwo].gameStatus[stats[pTwo].qOfGames] = CLOSED;
      stats[pOne].qOfGames += 1;
      stats[pTwo].qOfGames += 1;
      
      return DONE;
    }
  }
  
  function calcResOfGame(uint8 _resOne, uint8 _resTwo) pure returns (uint8) {
    if (_resOne == DONT_TELL_ANYTHING && _resTwo == DONT_TELL_ANYTHING) {
      return RESULT_HALF_HALF;
    }
    else if (_resOne == DONT_TELL_ANYTHING && _resTwo == TELL_EVERYTHING) {
      return RESULT_ZERO_TEN;
    }
    else if (_resOne == TELL_EVERYTHING && _resTwo == DONT_TELL_ANYTHING) {
      return RESULT_TEN_ZERO;
    }
    else if (_resOne == TELL_EVERYTHING && _resTwo == TELL_EVERYTHING) {
      return RESULT_TWO_TWO;
    }
  }
  
  function calcMyFinalRes() view returns (uint res) {
    for (uint i = 0; i <= stats[msg.sender].qOfGames; i++) {
      if (stats[msg.sender].results[i] == RESULT_HALF_HALF) {
        res += 1;
      }
      if (stats[msg.sender].results[i] == RESULT_ZERO_TEN) {
        if (stats[msg.sender].answer[i] == TELL_EVERYTHING) {
          res += 0;
        }
        else {
          res += 10;
        }
      }
      if (stats[msg.sender].results[i] == RESULT_TEN_ZERO) {
        if (stats[msg.sender].answer[i] == TELL_EVERYTHING) {
          res += 0;
        }
        else {
          res += 10;
        }
      }
      if (stats[msg.sender].results[i] == RESULT_TWO_TWO) {
        res += 2;
      }
    }
  }
  
  function seeMyScore() external view returns (uint res) {
    for (uint i = 0; i <= stats[msg.sender].qOfGames; i++) {
      if (stats[msg.sender].results[i] == RESULT_HALF_HALF) {
        res += 1;
      }
      if (stats[msg.sender].results[i] == RESULT_ZERO_TEN) {
        if (stats[msg.sender].answer[i] == TELL_EVERYTHING) {
          res += 0;
        }
        else {
          res += 10;
        }
      }
      if (stats[msg.sender].results[i] == RESULT_TEN_ZERO) {
        if (stats[msg.sender].answer[i] == TELL_EVERYTHING) {
          res += 0;
        }
        else {
          res += 10;
        }
      }
      if (stats[msg.sender].results[i] == RESULT_TWO_TWO) {
        res += 2;
      }
    }
  }
  
  function seeMyPartnerAnswer(uint _qGame) public view returns (uint8) {
    require(_qGame <= 9);
    address partner = stats[msg.sender].partner[_qGame];
    return stats[partner].answer[_qGame];
  }
  
  function seeMyQofGames() public view returns (uint) {
    return stats[msg.sender].qOfGames;
  }
  
  function seeMyAnswer(uint _qGame) public view returns (uint8) {
    require(_qGame <= 9);
    return stats[msg.sender].answer[_qGame];
  }
  
}