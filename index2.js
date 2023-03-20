$(`#btnGenerate`).on(`click`, async function (event) {
  await wd.walletGenerate();
  await wd.walletKey(wd.MNEMONIC);
  $(`#lblMnemonic`).html(wd.MNEMONIC);
  $(`#lblKey`).html(wd.KEY);
  $(`#lblAddress`).html(wd.ADDR);
  setCookie(`KEY`, wd.KEY);
  disCookie();
});

$(`#btnRandom`).on(`click`, function (event) {
  genRanBtns(`#lblRandom`, `#lblCorrect`, `#btnCont`);
});

$(`#btnImport`).on(`click`, async function (event) {
  await walletKey($(`#txtImport`).val());
  $(`#lblImport`).html(ADDR);
  setCookie(`KEY`, KEY);
  disCookie();
});

$(`#btnImKey`).on(`click`, async function (event) {
  await walletKey(``, $(`#txtImKey`).val());
  $(`#lblImport`).html(ADDR);
  setCookie(`KEY`, KEY);
  disCookie();
});

$(`#btnBSC`).on(`click`, async function (event) {
  await walletKey(``, getCookie(`KEY`));
  $(`#lblBSC`).html(await balanceBSC(ADDR));
  $(`#lblWD`).html(await balanceWDT(ADDR));
  $(`#lblPool`).html(await balanceWDT(C_2));
  $(`#txtCheckScore`).html(await getScore(ADDR));
});

$(`#btnScore`).on(`click`, async function (event) {
  $(`#btnScore`).html(await updateScore($(`#txtScore`).val(), KEY));
});

$(`#btnWithdraw`).on(`click`, async function (event) {
  $(`#btnWithdraw`).html(await withdrawal($(`#txtWithdraw`).val(), KEY));
});

$(`#btnDefault`).on(`click`, async function (event) {
  setCookie(
    `KEY`,
    `U2FsdGVkX1/Bukc8EAzpeYCfKWpmFFr+W1PWSCWDNjQQFoxzLHDKGF0WcDfKGN5+FtLKMhuj8yHaXC1wMqerJgdKLYF7TPcwpJVbxH74GL6/85Q/yD5Pciheh2Gecv2G`
  );
  await walletKey(``, getCookie(`KEY`));
  disCookie();
});

$(`#btnReset`).on(`click`, async function (event) {
  setCookie(`KEY`, ``);
  disCookie();
});

function disCookie() {
  if (typeof KEY != 'undefined') $(`#lblDefault`).html(KEY);
}
(async () => {
  await loadCookie();
  disCookie();
})();
