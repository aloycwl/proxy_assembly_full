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
  $('#btnRandom').show();
  $('#btnGenerate').remove();
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
  $('#lblMnemonic').remove();
  $('#btnRandom').remove();
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
    if (passed) {
      $('#lblRandom').remove();
      $('#lblCorrect').remove();
      $('#lblSequence').html('Correct 正确');
    } else $('#lblSequence').html('Wrong Sequence 顺序错');
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
