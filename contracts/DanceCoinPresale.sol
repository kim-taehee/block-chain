pragma solidity ^0.4.8;

 
import 'zeppelin-solidity/contracts/ownership/Ownable.sol'; 
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol'; 
import 'zeppelin-solidity/contracts/math/SafeMath.sol'; 
 
 
contract DanceCoinPresale is Ownable ,Pausable { 
     
    event PresaleTokenPurchase(address indexed buyer, address indexed beneficiary, uint256 toFund ); 
    
    uint256 public weiRaised;    
    uint256 public maxEtherCap; // 목표
    uint256 public gasLimit; 
    uint256 public startTime; //시작 시간
    uint256 public endTime; 
    bool public isFinalized; 
 
    mapping (address => uint256) public beneficiaryFunded; 

    // 생성자 
    function CoinPresale( 
    uint256 _startTime, 
    uint256 _endTime, 
    uint256 _maxEtherCap, 
    uint256 _gasLimit 
    ) { 
      
        require(_maxEtherCap > 0);  
        startTime = _startTime; 
        endTime = _endTime; 
        maxEtherCap = _maxEtherCap * (1 ether); 
        isFinalized = false; 
        weiRaised = 0x00; 
        gasLimit = _gasLimit; 
    }
     
    function () payable { 
        buyPresale(msg.sender); 
        
    }
    
    // 판매
    function buyPresale(address beneficiary) payable whenNotPaused { 
        require(!isFinalized); 
        require(beneficiary != 0x00); 
        require(validPurchase()); 
     
        uint256 toFund = msg.value; 
        uint256 postWeiRaised = SafeMath.add(weiRaised, toFund); 
        require(postWeiRaised <= maxEtherCap); 
        weiRaised = SafeMath.add(weiRaised, toFund); 
        beneficiaryFunded[beneficiary] = SafeMath.add(beneficiaryFunded[beneficiary], toFund); 
        
    } 
    
    // 판매 상황 추적 
    function validPurchase() internal constant returns (bool) { 
        bool validValue = msg.value >= 0.1 ether; 
        bool validTime = now >= startTime && now <= endTime; 
        return validValue && !maxReached() && validTime; 
    } 
 
 
    function maxReached() public constant returns (bool) { 
     return weiRaised >= maxEtherCap; 
    } 
 
 
    // 사용자 권한
    function changeStartTime( uint64 newStartTime ) public onlyOwner { 
        startTime = newStartTime; 
    } 
 
    function changeEndTime( uint64 newEndTime ) public onlyOwner { 
        endTime = newEndTime; 
    } 
 
    function changeMaxEtherCap(uint256 newMaxEtherCap) public onlyOwner { 
        maxEtherCap = newMaxEtherCap; 
    } 
 
    function changeGasLimit(uint256 newGasLimit) public onlyOwner { 
        gasLimit = newGasLimit; 
    }
    
    // 목표 도달 확인(기한 후 실시 가능)
    function FinishPresale() public onlyOwner { 
        require( maxReached() || now > endTime ); 
        isFinalized = true; 
        owner.transfer( weiRaised ); 
        
    } 
    
        
    
 } 


