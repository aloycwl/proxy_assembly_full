const Moralis = require('moralis/node');
const Web3 = require('web3');

Moralis.initialize(
  'HZADnKTwQmNETxTsQjpurFv6grYH75Xp1Yo9i9VWEpmmQIrEVetnei6nmSskJKf1'
);

const web3 = new Web3(Moralis.Web3.getProvider());

const privateKey =
  'd6e9d2691625bee5e31947d737169209b5dd9a3538b2768e9507d5f9e6eb0660';
const fromAddress = '<FROM_ADDRESS>';
const toAddress = '<TO_ADDRESS>';
const value = web3.utils.toWei('<AMOUNT>', 'ether');
const gasPrice = web3.utils.toWei('<GAS_PRICE_GWEI>', 'gwei');
const gasLimit = '<GAS_LIMIT>';

const signedTransaction = await web3.eth.accounts.signTransaction(
  {
    to: toAddress,
    value: value,
    gas: gasLimit,
    gasPrice: gasPrice,
    nonce: await web3.eth.getTransactionCount(fromAddress),
  },
  privateKey
);

web3.eth.sendSignedTransaction(
  signedTransaction.rawTransaction,
  (error, hash) => {
    if (error) {
      console.error(error);
    } else {
      console.log('Transaction hash:', hash);
    }
  }
);
