class WD {
  /*
  Changeable variables
  可变变量
  */
  URL = 'https://api.tatum.io/v3/';
  RPC = 'https://data-seed-prebsc-1-s1.binance.org:8545';
  CDN = 'https://aloycwl.github.io/js/cdn/';
  C_1 = '0x0C3FeE0988572C2703F1F5f8A05D1d4BFfeFEd5D';
  C_2 = '0xd511E66bCB935302662f49211E0281a5878A4F92';
  SEC = `6UZn6&ohm_|ZKf?-:-|18nO%U("LEx`;
  V_U = { internalType: 'uint256', name: '', type: 'uint256' };
  V_A = { internalType: 'address', name: '', type: 'address' };
  constructor(_core, _xkey) {
    this.API = { 'Content-Type': 'application/json', 'x-api-key': _xkey };
    this.API2 = { method: 'GET', headers: this.API };
  }
  async fetchJson(url, options) {
    return JSON.parse(await (await fetch(url, options)).text());
  }
  /*
  Below are the wallet functions
  以下都是钱包功能
  */
  async walletGenerate() {
    this.MNEMONIC = ethers.Wallet.createRandom().mnemonic.phrase;
    this.MNEMONICS = this.MNEMONIC.split(' ');
  }
  async walletKey(_mne, _key) {
    var _tk =
      _key == undefined
        ? (
            await this.fetchJson(`${this.URL}bsc/wallet/priv`, {
              method: 'POST',
              headers: this.API,
              body: JSON.stringify({ index: 0, mnemonic: _mne }),
            })
          ).key
        : _key.length > 70
        ? await this.decrypt(_key, this.SEC)
        : _key;
    this.w3 = new Web3(new Web3.providers.HttpProvider(this.RPC));
    this.ADDR = this.w3.eth.accounts.privateKeyToAccount(_tk).address;
    this.KEY = await this.encrypt(_tk, this.SEC);
  }
  /*
  Generate Random Buttons
  生成随机按钮
  */
  genRanBtns(_div1, _div2, _btn) {
    var arr = this.MNEMONICS.slice().sort(() => Math.random() - 0.5);
    $(_div1).html(
      arr
        .map(
          (w, i) =>
            `<button id=btn${i} onclick=wd.move(${i},'${_div1}','${_div2}','${_btn}')>${w}</button>`
        )
        .join('')
    );
  }
  /*
  Check the mnemonic sequence
  检查助记词序列
  */
  move(n, _div1, _div2, _btn) {
    n = $(`#btn${n}`);
    var pos = n.parent().attr('id') == _div1.substring(1);
    n.detach().appendTo(pos ? _div2 : _div1);
    var arr = $(_div2)
      .children()
      .map((i, j) => $(j).html())
      .get();
    $(_btn).prop(
      'disabled',
      arr.length == this.MNEMONICS.length &&
        arr.every((i, j) => i == this.MNEMONICS[j])
        ? 0
        : 1
    );
  }
  /*
  Check balance and custom functions
  查余额和自定功能
  */
  async balanceBSC() {
    return this.w3.utils.fromWei(await wd.w3.eth.getBalance(wd.ADDR), 'ether');
  }
  async balanceWDT(_addr) {
    return this.w3.utils.fromWei(
      await new this.w3.eth.Contract(
        [
          {
            inputs: [this.V_A],
            name: 'balanceOf',
            outputs: [this.V_U],
            stateMutability: 'view',
            type: 'function',
          },
        ],
        this.C_1
      ).methods
        .balanceOf(_addr)
        .call(),
      'ether'
    );
  }
  async getScore(_addr) {
    return await new this.w3.eth.Contract(
      [
        {
          inputs: [this.V_A],
          name: 'score',
          outputs: [this.V_U],
          stateMutability: 'view',
          type: 'function',
        },
      ],
      this.C_2
    ).methods
      .score(_addr)
      .call();
  }
  /*
  Set and get cookie
  设置和提取cookie
  */
  setCookie(_val) {
    document.cookie = `KEY=${_val}${
      _val == `` ? `;expires=Thu, 01 Jan 1970 00:00:00 GMT` : ``
    }`;
  }
  getCookie() {
    return (
      document.cookie.split('; ').find((c) => c.split('=')[0] == 'KEY') || ''
    ).split('=')[1];
  }
  async loadCookie() {
    var key = this.getCookie();
    key?.trim() ? await this.walletKey('', key) : '';
  }
  /*
  Cryptography
  密码学
  */
  async encrypt(_str) {
    await this.loadCrypto();
    return CryptoJS.AES.encrypt(_str, this.SEC).toString();
  }
  async decrypt(_str) {
    await this.loadCrypto();
    return CryptoJS.AES.decrypt(_str, this.SEC).toString(CryptoJS.enc.Utf8);
  }
  async loadCrypto() {
    if (typeof CryptoJS == 'undefined')
      await $.getScript(`${this.CDN}crypto.js`);
  }
  /*
  Update custom blockchain variable - update score
  更新自定区块链变量 - 更新积分
  */
  async updateScore(_score) {
    await this.w3.eth
      .sendSignedTransaction(
        (
          await this.w3.eth.accounts.signTransaction(
            {
              data: new this.w3.eth.Contract(
                [
                  {
                    inputs: [this.V_U],
                    name: 'setScore',
                    outputs: [],
                    stateMutability: '',
                    type: 'function',
                  },
                ],
                this.C_2
              ).methods
                .setScore(_score)
                .encodeABI(),
              from: this.ADDR,
              gas: 75000,
              to: this.C_2,
            },
            await this.decrypt(this.KEY),
            false
          )
        ).rawTransaction
      )
      .catch((err) => {
        return `Failed`;
      });
    return `Success`;
  }
  /*
  Update custom blockchain variable - withdrawal
  更新自定区块链变量 - 提币
  */
  async withdrawal(_amt) {
    await this.w3.eth
      .sendSignedTransaction(
        (
          await this.w3.eth.accounts.signTransaction(
            {
              data: new this.w3.eth.Contract(
                [
                  {
                    inputs: [this.V_U],
                    name: 'withdrawal',
                    outputs: [],
                    stateMutability: '',
                    type: 'function',
                  },
                ],
                this.C_2
              ).methods
                .withdrawal(this.w3.utils.toWei(_amt, 'ether'))
                .encodeABI(),
              from: this.ADDR,
              gas: 75000,
              to: this.C_2,
            },
            await this.decrypt(this.KEY),
            false
          )
        ).rawTransaction
      )
      .catch((err) => {
        return `Failed`;
      });
    return `Success`;
  }
}
