pragma solidity ^0.4.4;
import "./usingOraclize.sol";
import "./Help.sol";

contract Weather is usingOraclize {

	address public owner;
	uint public minAmount;
	uint public dayInsuranceBuffer;
	mapping (address => WeatherAccount) accounts;
	mapping (bytes32 => Result) oracleResults;



	struct Result {
		address account;
		uint index;
		bool returned;
	}
	struct WeatherAccount {
		Insurance[] insurances;
	}

	struct Insurance {
		string latitude;
		string longitude;
		uint totalPayout;
		uint date;
		bool claimed;
		bool exists;
		bytes32 oracleID;
		bool resultCollected;
		uint index;
	}


	function Weather() {
		OAR = OraclizeAddrResolverI(0x6f485c8bf6fc43ea212e93bbf8ce046c7f1cb475);
		owner = msg.sender;
		minAmount = 0;
		dayInsuranceBuffer = 1;
	}

	function getInsurance(uint index) constant returns (string, string , uint, uint, bool, bool, uint) {
		return (accounts[msg.sender].insurances[index].latitude,
			accounts[msg.sender].insurances[index].longitude,
			accounts[msg.sender].insurances[index].totalPayout,
			accounts[msg.sender].insurances[index].date,
			accounts[msg.sender].insurances[index].claimed,
			accounts[msg.sender].insurances[index].exists,
			accounts[msg.sender].insurances[index].index);
	}

	function getInsuranceLength() constant returns (uint activeIndexes) {
		return accounts[msg.sender].insurances.length;
	}

	function getInsurancesExists(uint index) constant returns (bool) {
		return accounts[msg.sender].insurances[index].exists;
	}


    function toHash(uint payout,
		uint initalAmount,
		string lat,
		string long,
		uint date,
		uint currentTime) constant returns (string) {
        string memory stringPayout = bytes32ToString(uintToBytes(payout));
        string memory stringInitalAmount = bytes32ToString(uintToBytes(initalAmount));
        string memory stringDate = bytes32ToString(uintToBytes(date));
        string memory stringCurrentTime = bytes32ToString(uintToBytes(currentTime));

        string memory firstSection = sconcat(
             stringPayout,
		 ",",stringInitalAmount,
		 ",",lat);
		 string memory secondSection = sconcat(
		     long,
		 ",",stringDate,
		 ",",stringCurrentTime);
		 return sconcat(firstSection,",",secondSection,"","");
    }



	function createInsurance(
		uint payout,
		uint initalAmount,
		string lat,
		string long,
		uint date,
		uint currentTime,
		bytes signature) payable {
		if(msg.value < minAmount) {
			throw;
		}
		if(now + (dayInsuranceBuffer * 1 days) >= date) {
		    Action("Rejected, date too soon", msg.sender);
			throw;
		}
		if(now >= currentTime+ 1 hours ) {
		    Action("Rejected, quote expired", msg.sender);
			throw;
		}
		if(initalAmount != msg.value) {
		    Action("Rejected, did not send correct amount", msg.sender);
			throw;
		}

        string memory stringHash = toHash(payout,initalAmount,lat,long,date,currentTime);
		bytes32 checkHash = sha3(stringHash);

		address returne;
		bool success;
		(success, returne) = ecrecovery(checkHash, signature);
		Hash(stringHash, checkHash, returne, msg.sender);

		//TODO IMPORTANT CHANGE TO NIKS PUBLIC KEY
		if(returne != 0xF877a551b354A18F689676ef702E7Fcedee56ae3) {
		    Action("Rejected, hash failed", msg.sender);
			throw;
		}
		//var payout = getPayoutQuote(lat, long, date, msg.value);
		var i = Insurance(lat, long, payout, date, false, true,
			0 , false, accounts[msg.sender].insurances.length);
		accounts[msg.sender].insurances.push(i);
		Action("Insurance placed!", msg.sender);
	}

	function payout(uint index) {
		if (!accounts[msg.sender].insurances[index].exists) {
		    Action("Payout doesn't exist?!", msg.sender);
				throw;
			}
		if (accounts[msg.sender].insurances[index].claimed) {
		    Action("Payout already claimed", msg.sender);
				throw;
			}
		if (now <= accounts[msg.sender].insurances[index].date + 1 days) {
		    Action("Cannot payout, it is not time yet", msg.sender);
				throw;
			}

		accounts[msg.sender].insurances[index].claimed = true;

        bytes32 myid = oraclize_query("URL", sconcat(sconcat("json(http://api.wunderground.com/api/323c0323a2c78fcd/history_",
		dateToString(accounts[msg.sender].insurances[index].date) , "/q/",
		accounts[msg.sender].insurances[index].latitude, ","),
		accounts[msg.sender].insurances[index].longitude , ".json", ").history.dailysummary[0].precipm" , ""));
		oracleResults[myid].account = msg.sender;
		oracleResults[myid].index = index;
		oracleResults[myid].returned = false;

		accounts[msg.sender].insurances[index].oracleID = myid;
        Action("Payout processing...", msg.sender);
	}

    function dateToString(uint date) constant returns (string) {
        Help.DateTime memory d = Help.parseTimestamp(date);

        string memory yyyy = bytes32ToString(uintToBytes(d.year));
        string memory mm = bytes32ToString(uintToBytes(d.month));
        string memory dd = bytes32ToString(uintToBytes(d.day));

				if(bytes(mm).length == 1) {
					mm = sconcat("0", mm, "","","");
				}
				if(bytes(dd).length == 1) {
					dd = sconcat("0", dd, "","","");
				}
        return sconcat(yyyy,mm, dd,"","");
    }

    function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
}

    function uintToBytes(uint v) constant returns (bytes32 ret) {
    if (v == 0) {
        ret = '0';
    }
    else {
        while (v > 0) {
            ret = bytes32(uint(ret) / (2 ** 8));
            ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
            v /= 10;
        }
    }
    return ret;
}


function sconcat(string _a, string _b, string _c, string _d, string _e) internal constant returns (string){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
}

	//Owner functions

	function forceCreateInsurance(string lat, string long,uint payout, uint date) onlyOwner
	payable {
		if(msg.value < minAmount) {
			throw;
		}


		var i = Insurance(lat, long, payout, date, false, true,
			0 , false, accounts[msg.sender].insurances.length);
		accounts[msg.sender].insurances.push(i);
	}

	function setMinAmount(uint newMinAmount) onlyOwner {
		minAmount = newMinAmount;
	}

	function setDayInsuranceBuffer(uint newDayInsuranceBuffer) onlyOwner {
		dayInsuranceBuffer = newDayInsuranceBuffer;
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


		//Oracle functions

		event oracleResult(bytes32 id, string result);

	function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) throw;
		oracleResult(myid, result);

		address sender = oracleResults[myid].account;

		//TODO parse result to bool
		bool res = !stringsEqual(result, "0.0");

		oracleResults[myid].returned = true;
		uint index = oracleResults[myid].index;

		if (res) {
		    Action("Payout success (it rained!): sending now", msg.sender);
			if(!sender.send(accounts[sender].insurances[index].totalPayout)) {
				accounts[sender].insurances[index].claimed  = false;
				Action("Sending failed, try again", msg.sender);
		    	}
		    } else {
		        Action("Payout denied: It didn't rain m8", msg.sender);
		    }
		}

		function stringsEqual(string memory _a, string memory _b) internal returns (bool) {
		bytes memory a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}

	function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
	internal returns (bool, address) {
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    function ecrecovery(bytes32 hash, bytes sig) returns (bool, address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
          return (false, 0);


        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27)
          v += 27;

        if (v != 27 && v != 28)
            return (false, 0);

        return safer_ecrecover(hash, v, r, s);
    }

    event Hash(string beforeHash, bytes32 afterHash, address returned, address person);
    event Action(string message, address person);
}
