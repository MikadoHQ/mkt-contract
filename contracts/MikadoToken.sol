pragma solidity ^0.4.21;

import './libs/Ownable.sol';
import './token/StandardToken.sol';
import './token/BurnableToken.sol';

/**
 * @title MikadoToken
 */
contract MikadoToken is StandardToken, BurnableToken, Ownable {

	event Release();
	event AddressLocked(address indexed _address, uint256 _time);

	string public constant name = "Mikado Token";

	string public constant symbol = "MKT";

	string public constant standard = "ERC20";

	uint256 public constant decimals = 8;

	bool public released = false;	

	address public holder;

	mapping(address => uint) public lockedAddresses;

	modifier isReleased () {
		require(released || msg.sender == holder || msg.sender == owner);
		require(lockedAddresses[msg.sender] <= now);
		_;
	}

	function MikadoToken() public {
		owner = 0x0; //TODO: add real address of token holder

		holder = owner;
		totalSupply_ = 540000000 * (10 ** decimals);
		balances[holder] = totalSupply_;
		emit Transfer(0x0, holder, totalSupply_);
	}

	function lockAddress(address _address, uint256 _time) public onlyOwner returns (bool) {
		require(balances[_address] == 0 && lockedAddresses[_address] == 0 && _time > now);
		lockedAddresses[_address] = _time;

		emit AddressLocked(_address, _time);
		return true;
	}

	function release() onlyOwner public returns (bool) {
		require(!released);
		released = true;
		emit Release();
		return true;
	}

	function getOwner() public view returns (address) {
		return owner;
	}

	function transfer(address _to, uint256 _value) public isReleased returns (bool) {
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public isReleased returns (bool) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public isReleased returns (bool) {
		return super.approve(_spender, _value);
	}

	function increaseApproval(address _spender, uint _addedValue) public isReleased returns (bool success) {
		return super.increaseApproval(_spender, _addedValue);
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public isReleased returns (bool success) {
		return super.decreaseApproval(_spender, _subtractedValue);
	}

	function transferOwnership(address newOwner) public onlyOwner {
		address oldOwner = owner;
		super.transferOwnership(newOwner);

		if (oldOwner != holder) {
			allowed[holder][oldOwner] = 0;
			emit Approval(holder, oldOwner, 0);
		}

		if (owner != holder) {
			allowed[holder][owner] = balances[holder];
			emit Approval(holder, owner, balances[holder]);
		}
	}

}
