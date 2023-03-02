/*
  Standard variable
*/
const API = {
    'Content-Type': 'application/json',
    'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
  },
  CHAIN = 'BSC',
  BEP20 = '0x86a3cA85fb4F1dB9028AF609036a4f8DA74A2458',
  KEY = '0x4dff39920956c6c23e259c0a674e4b405df0b7b3808e0165a05348b4e07afddc';

/*
  Generate function
  Needs 3 transaction to create mnemonic, private key and wallet address
*/
async function generate() {
  resp = await fetch(`https://api.tatum.io/v3/${CHAIN}/wallet`, {
    method: 'GET',
    headers: API,
  });
  data = JSON.parse(await resp.text());
  resp = await fetch(`https://api.tatum.io/v3/${CHAIN}/wallet/priv`, {
    method: 'POST',
    headers: API,
    body: JSON.stringify({
      index: 0,
      mnemonic: data.mnemonic,
    }),
  });
  resp = await fetch(
    `https://api.tatum.io/v3/${CHAIN}/address/${data.xpub}/${1}`,
    {
      method: 'GET',
      headers: API,
    }
  );
  data = JSON.parse(await resp.text());
  $('#addr').val(data.address);
  document.cookie = `addr=${data.address}`;
}

/*
  Check balance function
*/
async function balance() {
  address = $('#addr').val();
  resp = await fetch(
    `https://api.tatum.io/v3/blockchain/token/balance/${CHAIN}/${BEP20}/${address}`,
    {
      method: 'GET',
      headers: API,
    }
  );
  $('#bal').html(
    `Check balance 查余额 (${
      Number(JSON.parse(await resp.text()).balance) / 1e18
    })`
  );
}

/*
  Simulatate game function to generate rewards
*/
function game(x) {
  $('#amt').val(Number($('#amt').val()) + x);
  document.cookie = `amt=${x == 0 ? '0' : $('#amt').val()}`;
  unlock();
  $('#ttf').html('Transfer Out 转出');
}

/*
  Unlock for withdrawal function
*/
function unlock() {
  $('#ttf').prop('disabled', Number($('#amt').val()) > 50 ? false : true);
}

/*
  Send function with private key signing
  Reset the fields
*/
async function transfer() {
  resp = await fetch(`https://api.tatum.io/v3/blockchain/token/transaction`, {
    method: 'POST',
    headers: API,
    body: JSON.stringify({
      chain: CHAIN,
      to: $('#addr').val(),
      contractAddress: BEP20,
      amount: $('#amt').val(),
      digits: 18,
      fromPrivateKey: KEY,
    }),
  });
  $('#amt').val(0);
  game(0);
  $('#ttf').html('Transferred 已转出');
}

/*
  Getting the cookie value
*/
function getCookie(cname) {
  name = cname + '=';
  ca = decodeURIComponent(document.cookie).split(';');
  for (i = 0; i < ca.length; i++) {
    c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1);
    if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
  }
  return '';
}

/*
  Restart
*/
function clearC() {
  exp = '=; expires=Thu, 01 Jan 1970 00:00:00 UTC;';
  //document.cookie = 'addr' + exp;
  //document.cookie = 'amt' + exp;
  var Cookies = document.cookie.split(';');

  for (var i = 0; i < Cookies.length; i++)
    document.cookie = Cookies[i] + '=;expires=' + exp;

  location.href = '/';
}

/*
  Initialise, if existing player will not create new wallet
*/
if (getCookie('addr') == '') generate();
else {
  $('#addr').val(getCookie('addr'));
  $('#amt').val(getCookie('amt'));
  unlock();
}
