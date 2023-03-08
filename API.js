/*
Initialise
*/
API = {
  'Content-Type': 'application/json',
  'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
};

$('#btnBSC').on('click', async function (event) {
  web3 = new Web3(window.ethereum);
  key = web3.eth.accounts.privateKeyToAccount($('#txtKey').val());
  resp = await fetch(
    `https://api.tatum.io/v3/bsc/account/balance/${key.address}`,
    {
      method: 'GET',
      headers: API,
    }
  );
  data = await resp.text();
  $('#lblBSC').html(data);
});
