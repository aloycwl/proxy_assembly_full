const EthereumWallet = require('ethereumjs-wallet');

const wallet = EthereumWallet['default'].generate();

console.log('address: ' + wallet.getAddressString());
console.log('privateKey: ' + wallet.getPrivateKeyString());
