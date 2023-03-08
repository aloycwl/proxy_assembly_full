/*
Initialise
*/
API = {
  'Content-Type': 'application/json',
  'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
};
WDT = '0x1798f8B138B1eBFfc46467bd82eD1435923C7b63';
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
Check WD balance
*/
$('#btnScore').on('click', async function (event) {
  const resp = await fetch(`https://api.tatum.io/v3/bsc/smartcontract`, {
    method: 'POST',
    headers: ABI,
    body: JSON.stringify({
      contractAddress: '0xD4Bcde8373440E62193dce510cc84E74a3547Da0',
      methodName: 'upload',
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
    }),
  });
  const data = await resp.json();
  console.log(data);
});
