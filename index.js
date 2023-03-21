wd = new WD();

$(`#btnGenerate`).on(`click`, async function (event) {
  await wd.walletGenerate();
  await wd.walletKey(wd.MNEMONIC);
  $(`#lblMnemonic`).html(wd.MNEMONIC);
  $(`#lblKey`).html(wd.KEY);
  $(`#lblAddress`).html(wd.ADDR);
  wd.setCookie(wd.KEY);
  disCookie();
});

$(`#btnRandom`).on(`click`, function (event) {
  wd.genRanBtns(`#lblRandom`, `#lblCorrect`, `#btnCont`);
});

$(`#btnImport`).on(`click`, async function (event) {
  await wd.walletKey($(`#txtImport`).val());
  $(`#lblImport`).html(wd.ADDR);
  wd.setCookie(wd.KEY);
  disCookie();
});

$(`#btnImKey`).on(`click`, async function (event) {
  await wd.walletKey(``, $(`#txtImKey`).val());
  $(`#lblImport`).html(wd.ADDR);
  wd.setCookie(wd.KEY);
  disCookie();
});

$(`#btnBSC`).on(`click`, async function (event) {
  await wd.walletKey(``, wd.getCookie());
  $(`#lblBSC`).html(await wd.balanceBSC());
  $(`#lblWD`).html(await wd.balanceWDT(wd.ADDR, balanceOf));
  $(`#lblPool`).html(await wd.balanceWDT(wd.C_2));
  $(`#txtCheckScore`).html(await wd.getScore(wd.ADDR));
});

$(`#btnScore`).on(`click`, async function (event) {
  $(`#btnScore`).html(await wd.updateScore($(`#txtScore`).val()));
});

$(`#btnWithdraw`).on(`click`, async function (event) {
  $(`#btnWithdraw`).html(await wd.withdrawal($(`#txtWithdraw`).val()));
});

$(`#btnDefault`).on(`click`, async function (event) {
  wd.setCookie(
    `zV6W5n9xJHOm6Ff9u1VwsaJXHO9hZ6NmbwXt+zwmKhTgMBu68NhSRNDhgTo81tdiUkj4A9ljqvwbmy09pLXZofKamqaDBozOVJXX7hza6h8=`
  );
  await wd.walletKey(``, wd.getCookie());
  disCookie();
});

$(`#btnShow`).on(`click`, async function (event) {
  $(`#lblShow`).html(await wd.decrypt(wd.KEY));
});

$(`#btnReset`).on(`click`, async function (event) {
  wd.setCookie(``);
  delete wd.KEY;
  disCookie();
});

function disCookie() {
  $(`#lblDefault`).html(typeof wd.KEY != `undefined` ? wd.KEY : ``);
}

(async () => {
  await wd.loadCookie();
  disCookie();
})();
