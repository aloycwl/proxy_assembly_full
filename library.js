class WD {
  /*
  Changeable variables
  可变变量
  */
  v = {
    RPC: 'https://data-seed-prebsc-1-s1.binance.org:8545',
    C1: '0x0C3FeE0988572C2703F1F5f8A05D1d4BFfeFEd5D',
    C2: '0xd511E66bCB935302662f49211E0281a5878A4F92',
    SEC: '()#0uxm2pn)',
    U: { internalType: 'uint256', name: '', type: 'uint256' },
    A: { internalType: 'address', name: '', type: 'address' },
  };

  constructor() {
    this.ep = new ethers.providers.JsonRpcProvider(this.v.RPC);
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
    this.KEY =
      _key == undefined
        ? ethers.Wallet.fromMnemonic(_mne, `m/44'/60'/0'/0/0`).privateKey
        : _key.length > 70
        ? await this.decrypt(_key, this.v.SEC)
        : _key;
    this.ADDR = new ethers.Wallet(this.KEY).address;
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
    return ethers.utils.formatEther(await this.ep.getBalance(this.ADDR));
  }
  async balanceWDT(_addr) {
    return ethers.utils.formatEther(
      await new ethers.Contract(
        this.v.C1,
        [
          {
            inputs: [this.v.A],
            name: 'balanceOf',
            outputs: [this.v.U],
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
        this.v.C2,
        [
          {
            inputs: [this.v.A],
            name: 'score',
            outputs: [this.v.U],
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
  async setCookie(_val) {
    document.cookie = `KEY=${
      _val == ``
        ? `;expires=Thu, 01 Jan 1970 00:00:00 GMT`
        : await this.encrypt(_val)
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
  kd() {
    var keyData = new Uint8Array(16);
    keyData.set(new TextEncoder().encode(this.v.SEC).subarray(0, 16));
    return keyData;
  }
  async sk() {
    return await crypto.subtle.importKey(
      'raw',
      this.kd(),
      { name: 'AES-CBC' },
      false,
      ['encrypt', 'decrypt']
    );
  }
  async encrypt(_str) {
    return btoa(
      String.fromCharCode(
        ...new Uint8Array(
          await crypto.subtle.encrypt(
            { name: 'AES-CBC', iv: this.kd() },
            await this.sk(),
            new TextEncoder().encode(_str)
          )
        )
      )
    );
  }
  async decrypt(_str) {
    return new TextDecoder().decode(
      await crypto.subtle.decrypt(
        { name: 'AES-CBC', iv: this.kd() },
        await this.sk(),
        new Uint8Array(
          atob(_str)
            .split('')
            .map(function (c) {
              return c.charCodeAt(0);
            })
        )
      )
    );
  }
  /*
  Update custom blockchain variable - update score
  更新自定区块链变量 - 更新积分
  */
  async updateScore(_score) {
    try {
      await new ethers.Contract(
        this.v.C2,
        [
          {
            inputs: [this.v.U],
            name: 'setScore',
            outputs: [],
            stateMutability: '',
            type: 'function',
          },
        ],
        new ethers.Wallet(this.KEY, this.ep)
      ).setScore(_score);
      return 'Success';
    } catch (e) {
      return 'Insufficient Gas';
    }
  }
  /*
  Update custom blockchain variable - withdrawal
  更新自定区块链变量 - 提币
  */
  async withdrawal(_amt) {
    try {
      await new ethers.Contract(
        this.v.C2,
        [
          {
            inputs: [this.v.U],
            name: 'withdrawal',
            outputs: [],
            stateMutability: '',
            type: 'function',
          },
        ],
        new ethers.Wallet(this.KEY, this.ep)
      ).withdrawal(ethers.utils.parseEther(_amt));
      return 'Success';
    } catch (err) {
      return 'Insufficient Gas';
    }
  }
}
