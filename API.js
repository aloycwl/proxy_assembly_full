/*
Initialise, this simulate the storage of user's private key in their own device
启动, 这模拟了用户私钥在他们自己的设备中的存储
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
  if (updateScore.hasOwnProperty('txId')) {
    $('#txtScore').val('');
    $('#txtScore').attr('placeholder', 'Updated');
  }
});
/*
Fetch the updated score
*/
$('#btnCheckScore').on('click', async function (event) {
  new_score = await getScore(key.address);
  $('#txtCheckScore').html(new_score.data);
});
/*
Withdrawal
*/
$('#btnWithdraw').on('click', async function (event) {
  withdrawal = await withdrawal($('#txtWithdraw').val(), $('#txtKey').val());
  if (withdrawal.hasOwnProperty('txId')) {
    $('#txtWithdraw').val('');
    $('#txtWithdraw').attr('placeholder', 'Withdrawn');
  }
});
