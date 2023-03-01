const Web3 = require('web3');
const Tx = require('ethereumjs-tx').Transaction;

const web3 = new Web3(
  'https://goerli.infura.io/v3/d9dd32eb1ebe4bcf82626cd47e40fd22'
);

const abi = [
  {
    inputs: [
      {
        internalType: 'address',
        name: '',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    name: 'transfer',
    outputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    stateMutability: 'nonpayable',
    type: 'function',
  },
];
const contractAddress = '0x55d398326f99059fF775485246999027B3197955';
const tokenContract = new web3.eth.Contract(abi, contractAddress);

const fromAddress = '0x55d398326f99059fF775485246999027B3197955';
const privateKey = Buffer.from(
  'd6e9d2691625bee5e31947d737169209b5dd9a3538b2768e9507d5f9e6eb0660',
  'hex'
);

const toAddress = '0x55d398326f99059fF775485246999027B3197955';
const amount = web3.utils.toWei('1', 'ether');

const nonce = (async () => {
  await web3.eth.getTransactionCount(fromAddress);
})();
const gasPrice = (async () => {
  await web3.eth.getGasPrice();
})();

const txParams = {
  nonce: web3.utils.toHex(nonce),
  gasPrice: web3.utils.toHex(gasPrice),
  gasLimit: web3.utils.toHex(21000),
  to: contractAddress,
  value: '0x0',
  data: tokenContract.methods.transfer(toAddress, amount).encodeABI(),
};

const tx = new Tx(txParams, { chain: 'mainnet' });
tx.sign(privateKey);

const serializedTx = tx.serialize();

const transactionHash = (async () => {
  await web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'));
})();
