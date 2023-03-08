API = {
  'Content-Type': 'application/json',
  'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
};
WDT = '0x0C3FeE0988572C2703F1F5f8A05D1d4BFfeFEd5D';
CONTRACT_GAME = '0xd511E66bCB935302662f49211E0281a5878A4F92';
/*
Below are the wallet functions
以下都是钱包功能
*/
async function walletGenerate() {
  return JSON.parse(
    await (
      await fetch(`https://api.tatum.io/v3/bsc/wallet`, {
        method: 'GET',
        headers: API,
      })
    ).text()
  );
}
async function walletAddress(_addr) {
  return JSON.parse(
    await (
      await fetch(`https://api.tatum.io/v3/bsc/address/${_addr}/1`, {
        method: 'GET',
        headers: API,
      })
    ).text()
  );
}
async function walletPKey(_mne) {
  return await (
    await fetch(`https://api.tatum.io/v3/bsc/wallet/priv`, {
      method: 'POST',
      headers: API,
      body: JSON.stringify({
        index: 0,
        mnemonic: _mne,
      }),
    })
  ).json();
}
/*
Check balance functions
查余额功能
*/
async function balanceBSC(_addr) {
  return JSON.parse(
    await (
      await fetch(`https://api.tatum.io/v3/bsc/account/balance/${_addr}`, {
        method: 'GET',
        headers: API,
      })
    ).text()
  );
}
async function balanceWDT(_addr) {
  return JSON.parse(
    await (
      await fetch(
        `https://api.tatum.io/v3/blockchain/token/balance/BSC/${WDT}/${_addr}`,
        {
          method: 'GET',
          headers: API,
        }
      )
    ).text()
  );
}
