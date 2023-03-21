wd = new WD();

$(`#btnGenerate`).on(`click`, async function (event) {
  await wd.walletGenerate();
  await wd.walletKey(wd.MNEMONIC);
  $(`#lblMnemonic`).html(wd.MNEMONIC);
  $(`#lblKey`).html(wd.KEY);
  $(`#lblAddress`).html(wd.ADDR);
  await wd.setCookie(wd.KEY);
  disCookie();
});

$(`#btnRandom`).on(`click`, function (event) {
  wd.genRanBtns(`#lblRandom`, `#lblCorrect`, `#btnCont`);
});

$(`#btnImport`).on(`click`, async function (event) {
  await wd.walletKey($(`#txtImport`).val());
  $(`#lblImport`).html(wd.ADDR);
  await wd.setCookie(wd.KEY);
  disCookie();
});

$(`#btnImKey`).on(`click`, async function (event) {
  await wd.walletKey(``, $(`#txtImKey`).val());
  $(`#lblImport`).html(wd.ADDR);
  await wd.setCookie(wd.KEY);
  disCookie();
});

$(`#btnBSC`).on(`click`, async function (event) {
  await wd.walletKey(``, wd.getCookie());
  $(`#lblBSC`).html(await wd.balanceBSC());
  $(`#lblWD`).html(await wd.balanceWDT(wd.ADDR));
  $(`#lblPool`).html(await wd.balanceWDT(wd.v.C2));
  $(`#txtCheckScore`).html(await wd.getScore(wd.ADDR));
});

$(`#btnScore`).on(`click`, async function (event) {
  $(`#btnScore`).html(await wd.updateScore($(`#txtScore`).val()));
});

$(`#btnWithdraw`).on(`click`, async function (event) {
  $(`#btnWithdraw`).html(await wd.withdrawal($(`#txtWithdraw`).val()));
});

$(`#btnDefault`).on(`click`, async function (event) {
  await wd.setCookie(
    `d6e9d2691625bee5e31947d737169209b5dd9a3538b2768e9507d5f9e6eb0660`
  );
  await wd.walletKey(``, wd.getCookie());
  disCookie();
});

$(`#btnShow`).on(`click`, async function (event) {
  $(`#lblShow`).html(wd.KEY);
});

$(`#btnReset`).on(`click`, async function (event) {
  await wd.setCookie(``);
  delete wd.KEY;
  disCookie();
});

function disCookie() {
  $(`#lblDefault`).html(wd.getCookie());
}

(async () => {
  await wd.loadCookie();
  disCookie();
})();
