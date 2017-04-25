*This file is in progress and haven't been tested*

# Getting started

## Installation  
How to install the required dependencies.
### Website  
Install Meteor for running the website server:  
`$ curl https://install.meteor.com/ | sh`  

### Web 3 dependencies (Ethereum):  
**Make sure you have Node JS installed**:  
For arch Linux:  
`$ pacman -S nodejs npm`  
For Debian/Ubuntu:  
`$ curl -sL https://deb.nodesource.com/setup_6.10.2 | sudo -E bash -`  
`  sudo apt-get install -y nodejs`  
`$ sudo apt-get install -y build-essential`  
For Fedora:  
`$ sudo dnf install nodejs`

Once the *essential builds* are installed:  
`$ npm install -g ethereumjs-testrpc`  
`$ npm install -g truffle`  

### Metamask
Get the Google Chrome 'Metamask' Extension, use the strong Password123456789 after accepting the terms&conditions.  
We'll use the RPC http://localhost:8545 but more on this after running the different servers.

## Running

wether/WEther `$ meteor`  
wether/Ethereum `$ testrpc --mnemonic "my test example" --accounts 50`  
wether/Ethereum/ethereum-bridge `$ node bridge -a 49`  
wether/Ethereum `$ truffle migrate`  
  
Connect meta mask with secure password: Password123456789  
Connect on the private network  
