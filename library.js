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
const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
  return new Promise((resolve, reject) => {
      try {
          const scriptEle = document.createElement("script");
          scriptEle.type = type;
          scriptEle.async = async;
          scriptEle.src =FILE_URL;

          scriptEle.addEventListener("load", (ev) => {
              resolve({ status: true });
          });

          scriptEle.addEventListener("error", (ev) => {
              reject({
                  status: false,
                  message: `Failed to load the script ＄{FILE_URL}`
              });
          });

          document.body.appendChild(scriptEle);
      } catch (error) {
          reject(error);
      }
  });
};

loadScript("https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.3/jquery.slim.min.js")
  .then( data  => {
      console.log("Script loaded successfully", data);
  })
  .catch( err => {
      console.error(err);
  });
);
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
  return fetchJson(`${URL}bsc/wallet`, API2);
}
async function walletAddress(_addr) {
  return (await fetchJson(`${URL}bsc/address/${_addr}/1`, API2)).address;
}
async function walletKey(_mne) {
  return fetchJson(`${URL}bsc/wallet/priv`, {
    method: 'POST',
    headers: API,
    body: JSON.stringify({ index: 0, mnemonic: _mne }),
  });
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
