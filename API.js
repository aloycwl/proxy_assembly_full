//d6e9d2691625bee5e31947d737169209b5dd9a3538b2768e9507d5f9e6eb0660

/*
Initialise, this simulate the storage of user's private key in their own device
启动, 这模拟了用户私钥在他们自己的设备中的存储
*/
$('#txtKey').change(function () {
  web3 = new Web3(window.ethereum);
  key = web3.eth.accounts.privateKeyToAccount($('#txtKey').val());
});

$('#btnBSC').on('click', async function (event) {
  bsc = await balanceBSC(key.address);
  $('#lblBSC').html(bsc.balance);
});

$('#btnWD').on('click', async function (event) {
  wdt = await balanceWDT(key.address);
  $('#lblWD').html(wdt.balance);
});

$('#btnScore').on('click', async function (event) {
  _score = await updateScore($('#txtScore').val(), $('#txtKey').val());
  $('#btnScore').html(_score.hasOwnProperty('txId') ? 'Updated' : 'Error');
});

$('#btnCheckScore').on('click', async function (event) {
  _new_score = await getScore(key.address);
  $('#txtCheckScore').html(_new_score.data);
});

$('#btnWithdraw').on('click', async function (event) {
  _out = await withdrawal($('#txtWithdraw').val(), $('#txtKey').val());
  $('#btnWithdraw').html(_out.hasOwnProperty('txId') ? 'Withdrawn' : 'Error');
});
