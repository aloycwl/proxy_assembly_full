/*
Initialise
*/
$('#txtKey').change(function () {
  web3 = new Web3(window.ethereum);
  key = web3.eth.accounts.privateKeyToAccount($('#txtKey').val());
});
/*
Check BSC balance
*/
$('#btnBSC').on('click', async function (event) {
  bsc = await balanceBSC(key.address);
  $('#lblBSC').html(bsc.balance);
});
/*
Check WD balance
*/
$('#btnWD').on('click', async function (event) {
  wdt = await balanceWDT(key.address);
  $('#lblWD').html(wdt.balance);
});
/*
Write to score
*/
$('#btnScore').on('click', async function (event) {
  updateScore = await updateScore($('#txtScore').val(), $('#txtKey').val());
  console.log(updateScore);
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
  const resp = await fetch(`https://api.tatum.io/v3/bsc/smartcontract`, {
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
  const data = await resp.json();
  //console.log(data);
});
