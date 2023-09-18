// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "./swapContract.sol";
 
 contract AirdropProtocol{
address private    owner ;
address  private swapRouter;
uint256 private  systemFee ;
TokenSwap _swap ;
constructor( address _swapRouter ,uint256 _systemFee ){
owner = msg.sender ;
swapRouter = _swapRouter;
systemFee = _systemFee;
_swap = TokenSwap(_swapRouter);
}
//string=airdrops Name
//address of airdrops token
mapping(string =>address) private airdropList;
//string=airdrops Name
//address of user
//bool= user airdrop validation
mapping(string=>mapping(address=>bool)) private airdropParticipant;
//string : airdropName
//uint : the count of user that the participated
mapping(string=>uint)private AmountParticipants;
//string=name of airdrop
// amount of airdrop value
mapping(string=>uint) private airdropsValue;
//string: airdropName
//uint: airdrop deadline
mapping(string=>uint) private airdropDeadLine;
//string=name of airdrop
// amount of airdrop valid pariticipants
mapping(string =>uint) private countOfParticipants;

function getOwner()public view returns(address){
  return owner;
}

function getAirdropValidation(string memory airdropName)public view returns(bool){
  return airdropParticipant[airdropName][msg.sender];
}

function getCountOfParticipants(string memory airdropName)public view returns(uint){
 return countOfParticipants[airdropName];
}

function getAirdropsValue(string memory airdropName)public view returns(uint){
 return airdropsValue[airdropName];
}

function getAirdropList(string memory airdropName) public view returns(address){
return airdropList[airdropName];
}

function getAmountOfParticipants(string memory airdropName) public view returns(uint){
return AmountParticipants[airdropName];
}

function getAirdropDeadLine(string memory airdropName)public view returns(uint){
 return airdropDeadLine[airdropName];
}

/////---------------------------------------------------------------------------------------------------/////
function createAirdrop
(
  string memory airdropName,
   address airdropToken,
    uint airdropAmount,
     uint _airdropDeadLine,
      uint _countOfParticipants
      )
       public
        {
  require(msg.sender != address(0),"user cant be contract" );
  require(airdropList[airdropName]!=airdropToken,"this airdrop added");
  airdropList[airdropName] = airdropToken;
  airdropsValue[airdropName] = airdropAmount;
  countOfParticipants[airdropName]=_countOfParticipants;
  airdropDeadLine[airdropName]=_airdropDeadLine;
  _swap.swap(airdropToken , msg.sender , address(this),airdropAmount);
}
////___________________________////
function participate
(
  string memory airdropName
  )
  public
  {
require(block.timestamp <=airdropDeadLine[airdropName] , "Airdrop time has been finished");
require(!airdropParticipant[airdropName][msg.sender]  ,"this user has been participated" );
require(countOfParticipants[airdropName]>=AmountParticipants[airdropName]," the number of participants has been completed");
airdropParticipant[airdropName][msg.sender] = true;
AmountParticipants[airdropName]++;
}
////_________________________////
function payAirdrop
(
  string memory airdropName
  )
  public
   {
require(block.timestamp >=airdropDeadLine[airdropName] , "Airdrop time has not yet arrived");
require(airdropParticipant[airdropName][msg.sender] , "user has not participated in this airdrop");
airdropParticipant[airdropName][msg.sender] = false ;
uint airdropValue = airdropsValue[airdropName] / (AmountParticipants[airdropName]-1);
 airdropValue -= airdropValue*systemFee/100;
IERC20(airdropList[airdropName]).transfer(msg.sender , airdropValue);
IERC20(airdropList[airdropName]).transfer(owner , systemFee + airdropsValue[airdropName] % AmountParticipants[airdropName]);
}

 }