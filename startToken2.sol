// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract STT is ERC20,Ownable,ReentrancyGuard{
    using SafeMath for uint256;
    uint256[] public _unix_time_end;
    uint256[] public _amount_to_mint;
    uint256[] public _period_mint;
    uint256  _sell_fee;
    address  _fee_keeper;
    address public _minter;
    event changeSellFee(uint256 old_fee,uint256 new_fee);
    event changeFeeOwner(address old_fee_keeper,address new_fee_keeper);
    event changeMinter(address old_minter_address,address new_minter_address);
    event mintInPeriod(address owner,uint256 period,uint256 amount);
    event mintOutOfPeriod(address owner,uint256 amount);

    
    constructor() ERC20("Start Token","STT"){
        /**
        * There will distribute 400,000,000 STT in year 1
        *                       225,000,000 STT in year 2
        *                       175,000,000 STT in year 3
        *                       125,000,000 STT in year 4
        *                       75,000,000  STT in year 5
        **/
        uint32[5] memory amounts = [400000000, 225000000, 175000000, 125000000, 75000000];
        uint256 MINT_INTERVAL = 365 days;
        for(uint256 i = 0;i < amounts.length;i=i.add(1)){
            _unix_time_end.push((block.timestamp).add(i.mul(MINT_INTERVAL)));
            _amount_to_mint.push(amounts[i]*10**uint256(18));
            _period_mint.push(1);
        }
        _sell_fee = 20;
        _minter = owner();
    }

    

    function change_sell_fee(uint256 _fee)  external onlyOwner {
        require(_fee < 1000, "STT : invalid fee");
        emit changeSellFee(_sell_fee,_fee);
        _sell_fee = _fee;
    }

    function change_minter(address _address_minter)  external onlyOwner{
        require(_address_minter != address(0),"can't not be 0x address");
        emit changeMinter(_minter,_address_minter);
        _minter = _address_minter;
    }

    function change_fee_owner(address _keeper) external onlyOwner {
        require(_keeper != address(0),"can't not be 0x address");
        emit changeFeeOwner(_fee_keeper,_keeper);
        _fee_keeper = _keeper;
    }

    

    function mint_in_period(uint256 _period) external onlyOwner nonReentrant{
        require(_period < _unix_time_end.length,"STT : Period doesnt exist");
        require(block.timestamp > _unix_time_end[_period],"STT : Time is not reached to mint");
        require(_period_mint[_period] == 1,"STT : This period has minted");
        _mint(_minter,_amount_to_mint[_period]);
        _period_mint[_period] = 2;
        emit mintInPeriod(owner(),_period,_amount_to_mint[_period]);
    }

    function mint_out_of_period(uint256 amount) external onlyOwner nonReentrant{
        require(_unix_time_end.length > 0,"STT : dont have period");
        require(block.timestamp > _unix_time_end[_unix_time_end.length - 1],"STT : Cant use function util end period");
        _mint(_minter,amount);
        emit mintOutOfPeriod(owner(),amount);
    }

    function computeSellFee(uint256 tokenAmount) external view returns (uint256 fee, address to) {
        fee = tokenAmount * _sell_fee / 1000;
        to = _fee_keeper;
    }
}
