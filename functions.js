API = {
  'Content-Type': 'application/json',
  'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
};
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
