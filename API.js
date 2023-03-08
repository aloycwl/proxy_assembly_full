/*
Initialise
*/
API = {
  'Content-Type': 'application/json',
  'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
};
WDT = '0x1798f8B138B1eBFfc46467bd82eD1435923C7b63';
CONTRACT_GAME = '0xD4Bcde8373440E62193dce510cc84E74a3547Da0';
$('#txtKey').change(function () {
  web3 = new Web3(window.ethereum);
  key = web3.eth.accounts.privateKeyToAccount($('#txtKey').val());
});
/*
Check BSC balance
*/
$('#btnBSC').on('click', async function (event) {
  bsc = JSON.parse(
    await (
      await fetch(
        `https://api.tatum.io/v3/bsc/account/balance/${key.address}`,
        {
          method: 'GET',
          headers: API,
        }
      )
    ).text()
  );
  $('#lblBSC').html(bsc.balance);
});
/*
Check WD balance
*/
$('#btnWD').on('click', async function (event) {
  wdt = JSON.parse(
    await (
      await fetch(
        `https://api.tatum.io/v3/blockchain/token/balance/BSC/${WDT}/${key.address}`,
        {
          method: 'GET',
          headers: API,
        }
      )
    ).text()
  );
  $('#lblWD').html(wdt.balance);
});
/*
Write to score
*/
$('#btnScore').on('click', async function (event) {
  await fetch(`https://api.tatum.io/v3/bsc/smartcontract`, {
    method: 'POST',
    headers: API,
    body: JSON.stringify({
      contractAddress: CONTRACT_GAME,
      methodName: 'setScore',
      methodABI: {
        inputs: [
          {
            internalType: 'uint256',
            name: 'amt',
            type: 'uint256',
          },
        ],
        name: 'setScore',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
      },
      params: [$('#txtScore').val()],
      fromPrivateKey: $('#txtKey').val(),
    }),
  });
});
/*
Fetch the updated score
*/
$('#btnCheckScore').on('click', async function (event) {
  new_score = await (
    await fetch(`https://api.tatum.io/v3/bsc/smartcontract`, {
      method: 'POST',
      headers: API,
      body: JSON.stringify({
        contractAddress: CONTRACT_GAME,
        methodName: 'score',
        methodABI: {
          inputs: [
            {
              internalType: 'address',
              name: '',
              type: 'address',
            },
          ],
          name: 'score',
          outputs: [
            {
              internalType: 'uint256',
              name: '',
              type: 'uint256',
            },
          ],
          stateMutability: 'view',
          type: 'function',
        },
        params: [key.address],
      }),
    })
  ).json();
  $('#txtCheckScore').html(new_score.data);
});
/*
Withdrawal
*/
$('#btnWithdraw').on('click', async function (event) {
  await fetch(`https://api.tatum.io/v3/bsc/smartcontract`, {
    method: 'POST',
    headers: API,
    body: JSON.stringify({
      contractAddress: CONTRACT_GAME,
      methodName: 'withdrawal',
      methodABI: {
        inputs: [{ internalType: 'uint256', name: 'amt', type: 'uint256' }],
        name: 'withdrawal',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
      },
      params: [$('#txtWithdraw').val()],
      fromPrivateKey: $('#txtKey').val(),
    }),
  });
});
