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
