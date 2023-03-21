wd = new WD();

document
  .getElementById('btnGenerate')
  .addEventListener('click', async function (event) {
    await wd.walletGenerate();
    await wd.walletKey(wd.MNEMONIC);
    document.getElementById('lblMnemonic').innerHTML = wd.MNEMONIC;
    document.getElementById('lblKey').innerHTML = wd.KEY;
    document.getElementById('lblAddress').innerHTML = wd.ADDR;
    await wd.setCookie(wd.KEY);
    disCookie();
  });

document
  .getElementById('btnRandom')
  .addEventListener('click', function (event) {
    wd.genRanBtns('#lblRandom', '#lblCorrect', '#btnCont');
  });

document
  .getElementById('btnImport')
  .addEventListener('click', async function (event) {
    await wd.walletKey(document.getElementById('txtImport').value);
    document.getElementById('lblImport').innerHTML = wd.ADDR;
    await wd.setCookie(wd.KEY);
    disCookie();
  });

document
  .getElementById('btnImKey')
  .addEventListener('click', async function (event) {
    await wd.walletKey('', document.getElementById('txtImKey').value);
    document.getElementById('lblImport').innerHTML = wd.ADDR;
    await wd.setCookie(wd.KEY);
    disCookie();
  });

document
  .getElementById('btnBSC')
  .addEventListener('click', async function (event) {
    await wd.walletKey('', wd.getCookie());
    document.getElementById('lblBSC').innerHTML = await wd.balanceBSC();
    document.getElementById('lblWD').innerHTML = await wd.balanceWDT(wd.ADDR);
    document.getElementById('lblPool').innerHTML = await wd.balanceWDT(wd.v.C2);
    document.getElementById('txtCheckScore').innerHTML = await wd.getScore(
      wd.ADDR
    );
  });

document
  .getElementById('btnScore')
  .addEventListener('click', async function (event) {
    document.getElementById('btnScore').innerHTML = await wd.updateScore(
      document.getElementById('txtScore').value
    );
  });

document
  .getElementById('btnWithdraw')
  .addEventListener('click', async function (event) {
    document.getElementById('btnWithdraw').innerHTML = await wd.withdrawal(
      document.getElementById('txtWithdraw').value
    );
  });

document
  .getElementById('btnDefault')
  .addEventListener('click', async function (event) {
    await wd.setCookie(
      'd6e9d2691625bee5e31947d737169209b5dd9a3538b2768e9507d5f9e6eb0660'
    );
    await wd.walletKey('', wd.getCookie());
    disCookie();
  });

document
  .getElementById('btnShow')
  .addEventListener('click', async function (event) {
    document.getElementById('lblShow').innerHTML = wd.KEY;
  });

document
  .getElementById('btnReset')
  .addEventListener('click', async function (event) {
    await wd.setCookie('');
    delete wd.KEY;
    disCookie();
  });

function disCookie() {
  txt = wd.getCookie();
  document.getElementById('lblDefault').innerHTML = txt == undefined ? '' : txt;
}

(async () => {
  await wd.loadCookie();
  disCookie();
})();
