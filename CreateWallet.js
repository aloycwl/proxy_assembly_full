/*
Generate Wallet
生成钱包
*/
$('#btnGenerate').on('click', async function (event) {
  //Call function to generate 24 mnemonic
  //调用函数生成24个助记词
  pubkey = await walletGenerate();
  words = pubkey.mnemonic.split(' ');
  for (i = 0; i < words.length; i++)
    $('#lblMnemonic').append(`${words[i]}<br>`);

  //Call function to fetch address from public key
  //调用函数从公钥中获取地址
  address = await walletAddress(pubkey.xpub);
  $('#lblAddress').html(Web3.utils.toChecksumAddress(address.address));

  //Call function to fetch private key from mnemonic
  //调用函数从助记词中获取私钥
  privkey = await walletPKey(pubkey.mnemonic);
  $('#lblKey').html(privkey.key);
});

/*
Generate Random
生成随机
*/
$('#btnRandom').on('click', async function (event) {
  //Rearranging the mnemonic
  //重新排列助记符
  arr = words.slice();
  ci = arr.length;
  while (ci != 0) {
    ri = Math.floor(Math.random() * ci);
    ci--;
    [arr[ci], arr[ri]] = [arr[ri], arr[ci]];
  }
  //Display the mnemonic as buttons
  //将助记符显示为按钮
  for (i = 0; i < arr.length; i++) {
    $('#lblRandom').append(
      `<button id=btn${i} onclick=move(${i})>${arr[i]}</button>`
    );
  }
});

/*
Check the mnemonic sequence
检查助记词序列
*/
function move(n) {
  //Move the buttons inbetween the div
  //在 div 之间移动按钮
  n = '#btn' + n;
  if ($(n).parent().attr('id') == 'lblRandom')
    $(n).detach().appendTo('#lblCorrect');
  else $(n).detach().appendTo('#lblRandom');
  //Once done, check if sequence is correct
  //完成后，检查顺序是否正确
  if ($('#lblCorrect').children().length == words.length) {
    passed = true;
    for (i = 0; i < arr.length; i++)
      if ($($('#lblCorrect').children()[i]).html() != words[i]) passed = false;
    $('#lblSequence').html(passed ? 'Correct 正确' : 'Wrong Sequence 顺序错');
  }
}
