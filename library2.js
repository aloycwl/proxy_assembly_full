const XKEY = 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
  URL = 'https://api.tatum.io/v3/',
  CDN = 'https://aloycwl.github.io/js/cdn/',
  C_1 = '0x0C3FeE0988572C2703F1F5f8A05D1d4BFfeFEd5D',
  C_2 = '0xd511E66bCB935302662f49211E0281a5878A4F92',
  SEC = `6UZn6&ohm_|ZKf?-:-|18nO%U("LEx`;

(async () => {
  await import(`${CDN}jquery.js`);
  await $.getScript('index.js');
})();

const API = { 'Content-Type': 'application/json', 'x-api-key': XKEY },
  API2 = { method: 'GET', headers: API },
  UINT = { internalType: 'uint256', name: '', type: 'uint256' };

async function fetchJson(url, options) {
  return JSON.parse(await (await fetch(url, options)).text());
}

async function walletGenerate() {
  MNEMONIC = (await fetchJson(`${URL}bsc/wallet`, API2)).mnemonic
    .split(' ')
    .splice(0, 12)
    .join(' ');
  MNEMONICS = MNEMONIC.split(' ');
}

async function walletKey(_mne, _key) {
  _b = _key == undefined;
  _tk = _b
    ? (
        await fetchJson(`${URL}bsc/wallet/priv`, {
          method: 'POST',
          headers: API,
          body: JSON.stringify({ index: 0, mnemonic: _mne }),
        })
      ).key
    : await decrypt(_key, SEC);
  if (typeof Web3 == 'undefined') await $.getScript(`${CDN}web3.js`);
  web3 = new Web3(ethereum);
  ADDR = web3.eth.accounts.privateKeyToAccount(_tk).address;
  KEY = _b ? await encrypt(_tk, SEC) : _key;
}

function genRanBtns(_div1, _div2, _btn) {
  arr = MNEMONICS.slice().sort(() => Math.random() - 0.5);
  $(_div1).html(
    arr
      .map(
        (w, i) =>
          `<button id=btn${i} onclick=move(${i},'${_div1}','${_div2}','${_btn}')>${w}</button>`
      )
      .join('')
  );
}

function move(n, _div1, _div2, _btn) {
  n = $(`#btn${n}`);
  pos = n.parent().attr('id') == _div1.substring(1);
  n.detach().appendTo(pos ? _div2 : _div1);
  arr = $(_div2)
    .children()
    .map((i, j) => $(j).html())
    .get();
  $(_btn).prop(
    'disabled',
    arr.length == MNEMONICS.length && arr.every((i, j) => i == MNEMONICS[j])
      ? 0
      : 1
  );
}

async function balanceBSC(_addr) {
  return (
    await fetchJson(`${URL}bsc/account/balance/${_addr}`, {
      method: 'GET',
      headers: API,
    })
  ).balance;
}

async function balanceWDT(_addr) {
  return (
    (
      await fetchJson(`${URL}blockchain/token/balance/BSC/${C_1}/${_addr}`, {
        method: 'GET',
        headers: API,
      })
    ).balance / 1e18
  );
}
