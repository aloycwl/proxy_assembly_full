const resp = async () => {
  await fetch(`https://api.tatum.io/v3/bsc/wallet`, {
    method: 'GET',
    headers: {
      'x-api-key': 'f1384f0e-abd1-4d69-bb64-4682beb7fde4',
    },
  });
};
const data = async () => {
  await resp.text();
};
console.log(data);
