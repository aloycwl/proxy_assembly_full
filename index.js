/*
  Standard variable
*/
const API = {
    'Content-Type': 'application/json',
    'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
  },
  GET = { method: 'GET', headers: API },
  CHAIN = 'BSC',
  BEP20 = '0xF7DDe0a0A9BF7Def29F90Cdef2a4A0F0738C0c40',
  KEY = '0x4dff39920956c6c23e259c0a674e4b405df0b7b3808e0165a05348b4e07afddc',
  URL1 = `https://api.tatum.io/v3/${CHAIN}/`,
  URL2 = `https://api.tatum.io/v3/blockchain/token/`;

/*
  Generate function
  Needs 3 transaction to create mnemonic, private key and wallet address
*/
async function generate() {
  resp = await fetch(`${URL1}wallet`, GET);
  data = JSON.parse(await resp.text());
  resp = await fetch(`${URL1}wallet/priv`, {
    method: 'POST',
    headers: API,
    body: JSON.stringify({ index: 0, mnemonic: data.mnemonic }),
  });
  resp = await fetch(`${URL1}address/${data.xpub}/1`, GET);
  $('#addr').html(JSON.parse(await resp.text()).address);
  document.cookie = `addr=${$('#addr').html()}`;
}

/*
  Check balance function
*/
async function balance() {
  address = $('#addr').html();
  resp = await fetch(`${URL2}balance/${CHAIN}/${BEP20}/${address}`, GET);
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
  $('#amt').html(Number($('#amt').html()) + x);
  document.cookie = `amt=${x == 0 ? '0' : $('#amt').html()}`;
  unlock();
  $('#ttf').html('Transfer Out 转出');
}

/*
  Send function with private key signing
  Reset the fields
*/
async function transfer() {
  resp = await fetch(`${URL2}transaction`, {
    method: 'POST',
    headers: API,
    body: JSON.stringify({
      chain: CHAIN,
      to: $('#addr').html(),
      contractAddress: BEP20,
      amount: $('#amt').html(),
      digits: 18,
      fromPrivateKey: KEY,
    }),
  });
  $('#amt').html(0);
  game(0);
  $('#ttf').html('Transferred 已转出');
}

/*
  Unlock for withdrawal function
*/
function unlock() {
  $('#ttf').prop('disabled', Number($('#amt').html()) > 50 ? false : true);
}

/*
  Getting the cookie value
*/
function getC(name) {
  match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
  return match ? match[2] : '';
}

/*
  Restart
*/
function clearC() {
  co = document.cookie.split(';');
  for (i = 0; i < co.length; i++)
    document.cookie = co[i] + '=;expires=Thu, 01 Jan 1970 00:00:00 UTC';
  location.href = '/';
}

/*
  Initialise, if existing player will not create new wallet
*/
if (getC('addr') == '') generate();
else {
  $('#addr').html(getC('addr'));
  $('#amt').html(getC('amt'));
  unlock();
}
