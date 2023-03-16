/*
Initialise
启动
*/
API = {
  'Content-Type': 'application/json',
  'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
};
API2 = {
  method: 'GET',
  headers: API,
};
URL = 'https://api.tatum.io/v3/';
WDT = '0x0C3FeE0988572C2703F1F5f8A05D1d4BFfeFEd5D';
CONTRACT_GAME = '0xd511E66bCB935302662f49211E0281a5878A4F92';
/*
Function shortnerer
函数缩短器
*/
async function fetchJson(url, options) {
  return JSON.parse(await (await fetch(url, options)).text());
}
/*
Below are the wallet functions
以下都是钱包功能
*/
async function walletGenerate() {
  MNEMONIC = (await fetchJson(`${URL}bsc/wallet`, API2)).mnemonic
    .split(' ')
    .splice(0, 12)
    .join(' ');
  MNEMONICS = MNEMONIC.split(' ');
}
async function walletKey(_mne) {
  KEY = (
    await fetchJson(`${URL}bsc/wallet/priv`, {
      method: 'POST',
      headers: API,
      body: JSON.stringify({ index: 0, mnemonic: _mne }),
    })
  ).key;
  await $.getScript(
    'https://cdnjs.cloudflare.com/ajax/libs/web3/1.8.2/web3.min.js'
  ).done(function (s, t) {
    web3 = new Web3(ethereum);
    ADDR = web3.eth.accounts.privateKeyToAccount(KEY).address;
  });
}
/*Generate Random Buttons
  生成随机按钮
*/
function genRanBtns(_div1, _div2, _btn) {
  arr = MNEMONICS.slice();
  ci = arr.length;
  while (ci != 0) {
    ri = Math.floor(Math.random() * ci);
    ci--;
    [arr[ci], arr[ri]] = [arr[ri], arr[ci]];
  }
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
    .map(function () {
      return $(this).html();
    })
    .get();
  $(_btn).prop(
    'disabled',
    arr.length == MNEMONICS.length &&
      arr.every(function (i, j) {
        return i === MNEMONICS[j];
      })
      ? false
      : true
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
      await fetchJson(`${URL}blockchain/token/balance/BSC/${WDT}/${_addr}`, {
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
  return await (
    await fetch(`${URL}bsc/smartcontract`, {
      method: 'POST',
      headers: API,
      body: JSON.stringify({
        contractAddress: CONTRACT_GAME,
        methodName: 'setScore',
        methodABI: {
          inputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
          name: 'setScore',
          outputs: [],
          stateMutability: 'nonpayable',
          type: 'function',
        },
        params: [_score],
        fromPrivateKey: _key,
      }),
    })
  ).json();
}
/*
Update custom blockchain variable - withdrawal
更新自定区块链变量 - 提币
*/
async function withdrawal(_amt, _key) {
  return await (
    await fetch(`${URL}bsc/smartcontract`, {
      method: 'POST',
      headers: API,
      body: JSON.stringify({
        contractAddress: CONTRACT_GAME,
        methodName: 'withdrawal',
        methodABI: {
          inputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
          name: 'withdrawal',
          outputs: [],
          stateMutability: 'nonpayable',
          type: 'function',
        },
        params: [(Number(_amt) * 1e18).toString()],
        fromPrivateKey: _key,
      }),
    })
  ).json();
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
          contractAddress: CONTRACT_GAME,
          methodName: 'score',
          methodABI: {
            inputs: [{ internalType: 'address', name: '', type: 'address' }],
            name: 'score',
            outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
            stateMutability: 'view',
            type: 'function',
          },
          params: [_addr],
        }),
      })
    ).json()
  ).data;
}
