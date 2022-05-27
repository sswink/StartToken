// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract STT is ERC20,Ownable,ReentrancyGuard{
    using SafeMath for uint256;
    uint256[] _unix_time_end;
    uint256[] _amount_to_mint;
    uint256[] _period_mint;
    uint256 _sell_fee;
    address _fee_keeper;

    //1 year = 31536000s hex 0x1e13380
    // ["0x14adf4b7320334b90000000","0xba1d9a70c21cda81000000","0x90c1b1025e16710f000000","0x6765c793fa10079d000000","0x3e09de2596099e2b000000"]
    constructor(uint256 interval,uint256[] memory amounts) ERC20("Start Token","STT"){
        require(amounts.length > 0,"STT : Time & amounts Length is zero");
        for(uint256 i = 0;i < amounts.length;i=i.add(1)){
            _unix_time_end.push((block.timestamp).add(i.mul(interval)));
            _amount_to_mint.push(amounts[i]);
            _period_mint.push(1);
        }
        _sell_fee = 20;
    }

    

    function change_sell_fee(uint256 _fee) public onlyOwner {
        require(_fee < 1000, "STT : invalid fee");
        _sell_fee = _fee;
    }

    function change_fee_owner(address _keeper) public onlyOwner {
        _fee_keeper = _keeper;
    }

    function mint_in_period(uint256 _period) public onlyOwner nonReentrant{
        require(_period < _unix_time_end.length,"STT : Period doesnt exist");
        require(block.timestamp > _unix_time_end[_period],"STT : Time is not reached to mint");
        require(_period_mint[_period] == 1,"STT : This period has minted");
        _mint(owner(),_amount_to_mint[_period]);
        _period_mint[_period] = 2;
    }

    function mint_out_of_period(uint256 amount) public onlyOwner nonReentrant{
        require(_unix_time_end.length > 0,"STT : dont have period");
        require(block.timestamp > _unix_time_end[_unix_time_end.length - 1],"STT : Cant use function util end period");
        _mint(owner(),amount);
    }

    function get_unix_end_time(uint256 _period) public view returns(uint256) {
        return _unix_time_end[_period];
    }

    function get_amount_to_mint(uint256 _period) public view returns(uint256) {
        return _amount_to_mint[_period];
    }

    function get_period_mint(uint256 _period) public view returns(uint256) {
        return _period_mint[_period];
    }

    function computeSellFee(uint256 tokenAmount) external view returns (uint256 fee, address to) {
        fee = tokenAmount * _sell_fee / 1000;
        to = _fee_keeper;
    }
}
