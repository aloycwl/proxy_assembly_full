const Moralis = require('moralis').default;
const { EvmChain } = require('@moralisweb3/common-evm-utils');

const runApp = async () => {
  await Moralis.start({
    apiKey: 'HZADnKTwQmNETxTsQjpurFv6grYH75Xp1Yo9i9VWEpmmQIrEVetnei6nmSskJKf1',
  });

  const address = '0xc5513d7dda8fd8c6d6e7d4bcfec09e5c0b5dc469';

  const chain = EvmChain.ETHEREUM;

  const response = await Moralis.EvmApi.token.getWalletTokenBalances({
    address,
    chain,
  });

  console.log(response.toJSON());
};

runApp();
