pragma solidity ^0.4.4;

contract Weather {

	address public owner;
	mapping (address => WeatherAccount) accounts;

	struct WeatherAccount {
		Insurance[] insurances;
	}

	struct Insurance {
		int latitude;
		int longitude;
		int totalPayout;
		uint date;
		bool claimed;
		bool exists;
	}


	function Weather() {
		owner = msg.sender;
	}

	function getInsuranceLength() constant returns (uint activeIndexes) {
		return accounts[msg.sender].insurances.length;
	}

	function getInsurancesLat(uint index) constant returns (int) {
		return accounts[msg.sender].insurances[index].latitude;
	}

	function getInsurancesLong(uint index) constant returns (int) {
		return accounts[msg.sender].insurances[index].longitude;
	}

	function getInsurancesTotalPayout(uint index) constant returns (int) {
		return accounts[msg.sender].insurances[index].totalPayout;
	}

	function getInsurancesDate(uint index) constant returns (uint) {
		return accounts[msg.sender].insurances[index].date;
	}

	function getInsurancesClaimed(uint index) constant returns (bool) {
		return accounts[msg.sender].insurances[index].claimed;
	}

	function getInsurancesExists(uint index) constant returns (bool) {
		return accounts[msg.sender].insurances[index].exists;
	}

	function getPayoutQuote(int lat, int long, uint date, uint amount) constant returns (int payout) {

	}

	function createInsurance(int lat, int long, uint date) payable returns (bool success){

	}

	function payout(uint index) {
		if (!accounts[msg.sender].insurances[index].exists) {
				throw;
			}
		if (accounts[msg.sender].insurances[index].claimed) {
				throw;
			}
		if (now <= accounts[msg.sender].insurances[index].date + 1 days) {
			throw;
		}

		//Check it rained/did not rain
		bool didItRain = false;

		if (didItRain) {
			//payout them out

			//set
		}


	}

}
