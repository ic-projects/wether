pragma solidity ^0.4.4;

contract Weather {

	address public owner;
	uint public minAmount;
	mapping (address => WeatherAccount) accounts;

	struct WeatherAccount {
		Insurance[] insurances;
	}

	struct Insurance {
		int latitude;
		int longitude;
		uint totalPayout;
		uint date;
		bool claimed;
		bool exists;
	}


	function Weather() {
		owner = msg.sender;
		minAmount = 0;
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

	function getInsurancesTotalPayout(uint index) constant returns (uint) {
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

	function getPayoutQuote(int lat, int long, uint date, uint amount)
	constant returns (uint payout) {

		//TODO
		return amount * 2;
	}

	function getWeatherResult(int lat, int long, uint date)
	internal constant returns (bool didItRain) {


		//TODO
		return true;
	}

	function createInsurance(int lat, int long, uint date)
	payable returns (bool success) {
		if(msg.value < minAmount) {
			throw;
		}
		if(now + 5 days >= date) {
			throw;
		}


		var payout = getPayoutQuote(lat, long, date, msg.value);
		var i = Insurance(lat, long, payout, date, false, true);
		accounts[msg.sender].insurances.push(i);
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

		accounts[msg.sender].insurances[index].claimed = true;

		//Check it rained/did not rain
		bool didItRain = getWeatherResult(
			accounts[msg.sender].insurances[index].latitude,
			accounts[msg.sender].insurances[index].longitude,
			accounts[msg.sender].insurances[index].date);

		if (didItRain) {
			if(!msg.sender.send(accounts[msg.sender].insurances[index].totalPayout)) {
				accounts[msg.sender].insurances[index].claimed  = false;
			}
		}
	}





	//Owner functions

	function forceCreateInsurance(int lat, int long, uint date) onlyOwner
	payable returns (bool success) {
		if(msg.value < minAmount) {
			throw;
		}

		var payout = getPayoutQuote(lat, long, date, msg.value);
		var i = Insurance(lat, long, payout, date, false, true);
		accounts[msg.sender].insurances.push(i);
	}

	function setMinAmount(uint newMinAmount) onlyOwner {
		minAmount = newMinAmount;
	}

	function destroy() onlyOwner {
		suicide(owner);
	}

	modifier onlyOwner()
    {
        if (msg.sender != owner)
            throw;

        _;
    }


}
