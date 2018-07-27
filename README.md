# eth_prisoners_dilemma

## About 

There is a prisoner's dilemma in game theory. 
I use specific implementation when there is more than one round.

Important! Sometimes bet() has revert. It's normall try another time, in future it will be solved.

## Usage 

To play you need a smart contract where there will be such methods

```js

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

```

#### Most important

```js
 function bet(uint8 _answer) external returns (uint8 res);
```
Allows  you to set your bet.

**Only 2 variants 8 (tell police) or 10(don't tell police)**

To see your final score you need to use 

```js
 function seeMyScore(address _t) external view returns (uint res);
```

## Features

Allows to play only to smart contracts

Solve problem with timing 

