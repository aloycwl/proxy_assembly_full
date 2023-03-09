/*
Initialise
*/
$('#btnRandom').hide();

/*
Generate Wallet
*/
$('#btnGenerate').on('click', async function (event) {
  pubkey = await walletGenerate();
  words = pubkey.mnemonic.split(' ');
  for (i = 0; i < words.length; i++)
    $('#lblMnemonic').append(`${words[i]}<br>`);
  address = await walletAddress(pubkey.xpub);
  privkey = await walletPKey(pubkey.mnemonic);
});

/*
Generate Random
*/
$('#btnRandom').on('click', async function (event) {
  arr = words.slice();
  ci = arr.length;
  while (ci != 0) {
    ri = Math.floor(Math.random() * ci);
    ci--;
    [arr[ci], arr[ri]] = [arr[ri], arr[ci]];
  }
  for (i = 0; i < arr.length; i++) {
    $('#lblRandom').append(
      `<button id=btn${i} onclick=move(${i})>${arr[i]}</button>`
    );
  }
});

/*
Check the mnemonic sequence
*/
function move(n) {
  n = '#btn' + n;
  if ($(n).parent().attr('id') == 'lblRandom')
    $(n).detach().appendTo('#lblCorrect');
  else $(n).detach().appendTo('#lblRandom');
  if ($('#lblCorrect').children().length == words.length) {
    passed = true;
    for (i = 0; i < arr.length; i++)
      if ($($('#lblCorrect').children()[i]).html() != words[i]) passed = false;
    $('#lblSequence').html(passed ? 'Correct 正确' : 'Wrong Sequence 顺序错');
  }
}

/*
Show wallet address
*/
$('#btnAddr').on('click', async function (event) {
  $('#lblAddress').html(Web3.utils.toChecksumAddress(address.address));
});

/*
Show wallet key
*/
$('#btnKey').on('click', async function (event) {
  $('#lblKey').html(privkey.key);
});
