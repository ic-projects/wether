import { Template } from 'meteor/templating';
import React, { Component, PropTypes } from 'react';
import { Mongo } from 'meteor/mongo';
import ReactDOM from 'react-dom';
import { ReactiveVar } from 'meteor/reactive-var';
Insurances = new Mongo.Collection(null);

import '../index.html';

let abi = [
  {
    "constant": true,
    "inputs": [],
    "name": "dayInsuranceBuffer",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "lat",
        "type": "int256"
      },
      {
        "name": "long",
        "type": "int256"
      },
      {
        "name": "date",
        "type": "uint256"
      }
    ],
    "name": "createInsurance",
    "outputs": [],
    "payable": true,
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "lat",
        "type": "int256"
      },
      {
        "name": "long",
        "type": "int256"
      },
      {
        "name": "date",
        "type": "uint256"
      },
      {
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "getPayoutQuote",
    "outputs": [
      {
        "name": "payout",
        "type": "uint256"
      }
    ],
    "payable": false,
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "lat",
        "type": "int256"
      },
      {
        "name": "long",
        "type": "int256"
      },
      {
        "name": "date",
        "type": "uint256"
      }
    ],
    "name": "forceCreateInsurance",
    "outputs": [
      {
        "name": "success",
        "type": "bool"
      }
    ],
    "payable": true,
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "destroy",
    "outputs": [],
    "payable": false,
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "index",
        "type": "uint256"
      }
    ],
    "name": "getInsurance",
    "outputs": [
      {
        "name": "",
        "type": "int256"
      },
      {
        "name": "",
        "type": "int256"
      },
      {
        "name": "",
        "type": "uint256"
      },
      {
        "name": "",
        "type": "uint256"
      },
      {
        "name": "",
        "type": "bool"
      },
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "newMinAmount",
        "type": "uint256"
      }
    ],
    "name": "setMinAmount",
    "outputs": [],
    "payable": false,
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "payable": false,
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "minAmount",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "getInsuranceLength",
    "outputs": [
      {
        "name": "activeIndexes",
        "type": "uint256"
      }
    ],
    "payable": false,
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "index",
        "type": "uint256"
      }
    ],
    "name": "getInsurancesExists",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "newDayInsuranceBuffer",
        "type": "uint256"
      }
    ],
    "name": "setDayInsuranceBuffer",
    "outputs": [],
    "payable": false,
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "index",
        "type": "uint256"
      }
    ],
    "name": "payout",
    "outputs": [],
    "payable": false,
    "type": "function"
  },
  {
    "inputs": [],
    "payable": false,
    "type": "constructor"
  }
];
let contractAddress = "0x279e0d42bd5f724694443478c8d3b7937afab75a";
let Contract = web3.eth.contract(abi);
let contractInstance = Contract.at(contractAddress);

function Insurance(longitude, latitude, totalPayout, date, claimed) {
  this.longitude = longitude;
  this.latitude = latitude;
  this.totalPayout = totalPayout;
  this.date = date;
  this.claimed = claimed;
}

Meteor.startup(function() {
  contractInstance.getInsuranceLength(function(error, result) {
    if (error) {
      console.log("Error: " + error);
      return;
    }

    // Display number of insurances to the user
    document.getElementById("insurance-number").innerHTML = String(result);

    // Build up the list of Insurance objects
    for (i = 0; i < parseInt(result); i++) {
      contractInstance.getInsurance(i, function(error, result) {
        if (error) {
          console.log("Error: " + error);
          return;
        }

        /*
         * Result tuple order:
         * 0: latitude
         * 1: longitude
         * 2: totalPayout
         * 3: date
         * 4: claimed
         * 5: exists
         */

        if (result[5]) {
          Insurances.insert({
            longitude: parseInt(result[0]),
            latitude: parseInt(result[1]),
            totalPayout: web3.fromWei(String(result[2]), "ether"),
            date: parseInt(result[3]),
            claimed: result[4]
          });
        }
      });
    }
  });
});

// contractInstance.createInsurance.sendTransaction(980, 69, 14917829900, {value: web3.toWei(1, "ether")}, function(error, result) {
//   alert(error);
//   console.log(result);
// });

Template.debug.helpers({
  insurances: function() {
    return Insurances.find().fetch();
  }
});