pragma solidity ^0.4.24;

contract IGame {
  
  uint8 constant DONT_TELL_ANYTHING = 8;
  uint8 constant TELL_EVERYTHING = 10;
  
  function bet(uint8 _answer) external returns (uint8 res);
  
  function seeMyScore(address _t) external view returns (uint res);
  
  function seeMyPartnerAnswer(uint id, address _t) public view returns (uint8);
  
  function seeMyQofGames(address _t) public view returns (uint);
  
  function seeMyAnswer(uint _qGame, address _t) public view returns (uint8);
  
  function seeMyAnswers(address _t) public view returns (uint8[9]);
  
  function seeMyPartners(address _t) public view returns (address[9]);
  
  function seeMyIds(address _t) public view returns (uint[9]);
  
  function seeMyId(uint _qGame, address _t) public view returns (uint);
}

contract Player {
  
  address target;
  
  constructor(address _target) {
    target = _target;
  }
  
  function setBet() {
    IGame I = IGame(target);
    I.bet(0x8);
  }
  
}

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
  
  uint8 currentMatchingStatus;
  
  uint time;
  
  struct Stats {
    uint256 qOfGames;
    uint8 [9] results;
    uint8 [9] answer;
    address [9] partner;
    uint8 [9] gameStatus;
    mapping(uint => uint8) partnerRes;
    uint [9] gameIds;
  }
  
  mapping(address => Stats) stats;
  
  function bet(uint8 _answer) external returns (uint8 res) {
    require(stats[msg.sender].gameStatus[stats[msg.sender].qOfGames] != OPENED);
    stats[msg.sender].answer[stats[msg.sender].qOfGames] = _answer;
    stats[msg.sender].gameStatus[stats[msg.sender].qOfGames] = OPENED;
    res = play(msg.sender);
  }
  
  function timeout() private {
    time = block.timestamp + 10;
  }
  
  function play(address _player) private returns (uint8) {
    require(block.timestamp >= time, "please, wait a bit");
    timeout();
    
    currentPlayers.push(_player);
    len++;
    
    if (len == 1) {
      currentMatchingStatus = IN_PROGRESS;
      return currentMatchingStatus;
    }
    else if (len % 2 != 0 && currentMatchingStatus == DONE) {
      currentMatchingStatus = IN_PROGRESS;
      return currentMatchingStatus;
    }
    else if (len % 2 == 0 && currentMatchingStatus == IN_PROGRESS) {
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
      stats[pTwo].gameIds[stats[pTwo].qOfGames] = block.timestamp;
      stats[pOne].gameIds[stats[pTwo].qOfGames] = block.timestamp;
      stats[pTwo].partnerRes[stats[pTwo].gameIds[stats[pTwo].qOfGames]] = _resOne;
      stats[pOne].partnerRes[stats[pOne].gameIds[stats[pOne].qOfGames]] = _resTwo;
      stats[pOne].qOfGames += 1;
      stats[pTwo].qOfGames += 1;
      currentMatchingStatus = DONE;
      return currentMatchingStatus;
    }
    else {
      play(_player);
    }
  }
  
  function calcResOfGame(uint8 _resOne, uint8 _resTwo) private pure returns (uint8) {
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
  
  function seeMyScore(address _t) external view returns (uint res) {
    for (uint i = 0; i <= stats[msg.sender].qOfGames; i++) {
      if (stats[_t].results[i] == RESULT_HALF_HALF) {
        res += 1;
      }
      if (stats[msg.sender].results[i] == RESULT_ZERO_TEN) {
        if (stats[_t].answer[i] == TELL_EVERYTHING) {
          res += 0;
        }
        else {
          res += 10;
        }
      }
      if (stats[msg.sender].results[i] == RESULT_TEN_ZERO) {
        if (stats[_t].answer[i] == TELL_EVERYTHING) {
          res += 0;
        }
        else {
          res += 10;
        }
      }
      if (stats[_t].results[i] == RESULT_TWO_TWO) {
        res += 2;
      }
    }
  }
  
  function seeMyPartnerAnswer(uint id, address _t) public view returns (uint8) {
    return stats[_t].partnerRes[id];
  }
  
  function seeMyQofGames(address _t) public view returns (uint) {
    return stats[_t].qOfGames;
  }
  
  function seeMyAnswer(uint _qGame, address _t) public view returns (uint8) {
    require(_qGame <= 9);
    return stats[_t].answer[_qGame];
  }
  
  function seeMyAnswers(address _t) public view returns (uint8[9]) {
    return stats[_t].answer;
  }
  
  function seeMyPartners() public view returns (address[9]) {
    return stats[msg.sender].partner;
  }
  
  function seeMyIds(address _t) public view returns (uint[9]) {
    return stats[_t].gameIds;
  }
  
  function seeMyId(uint _qGame, address _t) public view returns (uint) {
    return stats[_t].gameIds[_qGame];
  }
  
}