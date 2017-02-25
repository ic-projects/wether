pragma solidity ^0.4.4;

contract Weather {

	address public owner;
	
		function Weather() {
			owner = msg.sender;
		}
}
