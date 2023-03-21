class WD {
  /*
  Changeable variables
  可变变量
  */
  RPC = 'https://data-seed-prebsc-1-s1.binance.org:8545';
  CDN = 'https://aloycwl.github.io/js/cdn/';
  C_1 = '0x0C3FeE0988572C2703F1F5f8A05D1d4BFfeFEd5D';
  C_2 = '0xd511E66bCB935302662f49211E0281a5878A4F92';
  SEC = `6UZn6&ohm_|ZKf?-:-|18nO%U("LEx`;
  V_U = { internalType: 'uint256', name: '', type: 'uint256' };
  V_A = { internalType: 'address', name: '', type: 'address' };
  constructor() {
    this.ep = new ethers.providers.JsonRpcProvider(this.RPC);
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
        ? ethers.Wallet.fromMnemonic(_mne, `m/44'/60'/0'/0/0`).privateKey
        : _key.length > 70
        ? await this.decrypt(_key, this.SEC)
        : _key;
    this.ADDR = new ethers.Wallet(_tk).address;
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
    return ethers.utils.formatEther(await this.ep.getBalance(wd.ADDR));
  }
  async balanceWDT(_addr) {
    return ethers.utils.formatEther(
      await new ethers.Contract(
        this.C_1,
        [
          {
            inputs: [this.V_A],
            name: 'balanceOf',
            outputs: [this.V_U],
            stateMutability: 'view',
            type: 'function',
          },
        ],
        this.ep
      ).balanceOf(_addr)
    );
  }
  async getScore(_addr) {
    return ethers.utils.formatUnits(
      await new ethers.Contract(
        this.C_2,
        [
          {
            inputs: [this.V_A],
            name: 'score',
            outputs: [this.V_U],
            stateMutability: 'view',
            type: 'function',
          },
        ],
        this.ep
      ).score(_addr),
      'wei'
    );
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
    var txt = 'Success';
    await new ethers.Contract(
      this.C_2,
      [
        {
          inputs: [this.V_U],
          name: 'setScore',
          outputs: [],
          stateMutability: '',
          type: 'function',
        },
      ],
      new ethers.Wallet(await this.decrypt(this.KEY), this.ep)
    )
      .setScore(_score)
      .catch((e) => {
        txt = 'Insufficent Gas';
      });
    return txt;
  }
  /*
  Update custom blockchain variable - withdrawal
  更新自定区块链变量 - 提币
  */
  async withdrawal(_amt) {
    var txt = 'Success';
    await new ethers.Contract(
      this.C_2,
      [
        {
          inputs: [this.V_U],
          name: 'withdrawal',
          outputs: [],
          stateMutability: '',
          type: 'function',
        },
      ],
      new ethers.Wallet(await this.decrypt(this.KEY), this.ep)
    )
      .withdrawal(ethers.utils.parseEther(_amt))
      .catch((err) => {
        txt = 'Insufficent Gas';
      });
    return txt;
  }
}
