*This file is in progress and haven't been tested*

#How to install the required dependencies:

Install Meteor for running the server:  
`$ curl https://install.meteor.com/ | sh`  

Web 3 dependencies:  
**Make sure you have Node JS installed**:  
For arch Linux:  
`$ pacman -S nodejs npm`  
For Debian/Ubuntu:  
`$ curl -sL https://deb.nodesource.com/setup_6.10.2 | sudo -E bash -  
sudo apt-get install -y nodejs`
`$ sudo apt-get install -y build-essential`  
For Fedora:  
`$ sudo dnf install nodejs`

Once the *essential builds* are installed:  
`$ npm install -g ethereumjs-testrpc` 
`$ npm install -g truffle`  

Get the Google Chrome 'Metamask' Extension,use the strong Password123456789 after accepting the terms&conditions.  
We'll use the RPC http://localhost:8545 but more on this after running the different servers.
