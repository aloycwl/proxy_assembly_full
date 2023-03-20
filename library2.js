class WD {
  /*
  Changeable variables
  可变变量
  */
  URL = 'https://api.tatum.io/v3/';
  CDN = 'https://aloycwl.github.io/js/cdn/';
  C_1 = '0x0C3FeE0988572C2703F1F5f8A05D1d4BFfeFEd5D';
  C_2 = '0xd511E66bCB935302662f49211E0281a5878A4F92';
  SEC = `6UZn6&ohm_|ZKf?-:-|18nO%U("LEx`;
  API = {};
  API2 = {};
  UINT = { internalType: 'uint256', name: '', type: 'uint256' };
  constructor(_core, _xkey) {
    this.preload(_core);
    this.API = { 'Content-Type': 'application/json', 'x-api-key': _xkey };
    this.API2 = { method: 'GET', headers: this.API };
  }
  /*Preloading
  预加载
  */
  async preload(_core) {
    await import(`${this.CDN}jquery.js`);
    await $.getScript(_core);
  }
  async fetchJson(url, options) {
    const response = await fetch(url, options);
    const text = await response.text();
    return JSON.parse(text);
  }
  /*
  Below are the wallet functions
  以下都是钱包功能
  */
  async walletGenerate() {
    MNEMONIC = (await fetchJson(`${URL}bsc/wallet`, API2)).mnemonic
      .split(' ')
      .splice(0, 12)
      .join(' ');
    MNEMONICS = MNEMONIC.split(' ');
  }
  async walletKey(_mne, _key) {
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
}

/*Generate Random Buttons
  生成随机按钮
*/
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
/*
  Check the mnemonic sequence
  检查助记词序列
*/
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
/*
Check balance functions
查余额功能
*/
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
/*
Update custom blockchain variable - update score
更新自定区块链变量 - 更新积分
*/
async function updateScore(_score, _key) {
  return getMessage(
    await (
      await fetch(`${URL}bsc/smartcontract`, {
        method: 'POST',
        headers: API,
        body: JSON.stringify({
          contractAddress: C_2,
          methodName: 'setScore',
          methodABI: {
            inputs: [UINT],
            name: 'setScore',
            outputs: [],
            stateMutability: '',
            type: 'function',
          },
          params: [_score],
          fromPrivateKey: await decrypt(_key, SEC),
        }),
      })
    ).json()
  );
}
/*
Update custom blockchain variable - withdrawal
更新自定区块链变量 - 提币
*/
async function withdrawal(_amt, _key) {
  return getMessage(
    await (
      await fetch(`${URL}bsc/smartcontract`, {
        method: 'POST',
        headers: API,
        body: JSON.stringify({
          contractAddress: C_2,
          methodName: 'withdrawal',
          methodABI: {
            inputs: [UINT],
            name: 'withdrawal',
            outputs: [],
            stateMutability: '',
            type: 'function',
          },
          params: [
            (Number(_amt) * 1e18).toLocaleString('fullwide', {
              useGrouping: false,
            }),
          ],
          fromPrivateKey: await decrypt(_key, SEC),
        }),
      })
    ).json()
  );
}
/*
Return message from chain transaction
链交易返回消息
*/
function getMessage(_json) {
  return _json.hasOwnProperty(`txId`)
    ? `Success`
    : _json.hasOwnProperty(`cause`)
    ? _json.cause
    : _json.message;
}
/*
Fetch custom blockchain variable
取自定区块链变量
*/
async function getScore(_addr) {
  return (
    await (
      await fetch(`${URL}bsc/smartcontract`, {
        method: 'POST',
        headers: API,
        body: JSON.stringify({
          contractAddress: C_2,
          methodName: 'score',
          methodABI: {
            inputs: [{ internalType: 'address', name: '', type: 'address' }],
            name: 'score',
            outputs: [UINT],
            stateMutability: 'view',
            type: 'function',
          },
          params: [_addr],
        }),
      })
    ).json()
  ).data;
}
/*
Set and get cookie
设置和提取cookie
*/
function setCookie(_var, _val) {
  document.cookie = `${_var}=${_val}${
    _val == `` ? `;expires=Thu, 01 Jan 1970 00:00:00 GMT` : ``
  }`;
}
function getCookie(_var) {
  return (
    document.cookie.split('; ').find((c) => c.split('=')[0] == _var) || ''
  ).split('=')[1];
}
async function loadCookie() {
  key = getCookie('KEY');
  key?.trim() ? await walletKey('', key) : '';
}
/*
Cryptography
密码学
*/
async function encrypt(_str, _sec) {
  await loadCrypto();
  return CryptoJS.AES.encrypt(_str, _sec).toString();
}
async function decrypt(_str, _sec) {
  await loadCrypto();
  return CryptoJS.AES.decrypt(_str, _sec).toString(CryptoJS.enc.Utf8);
}
async function loadCrypto() {
  if (typeof CryptoJS == 'undefined') await $.getScript(`${CDN}crypto.js`);
}
