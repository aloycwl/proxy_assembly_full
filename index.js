$(`#btnGenerate`).on(`click`, async function (event) {
  await walletGenerate();
  await walletKey(MNEMONIC);
  $(`#lblMnemonic`).html(MNEMONIC);
  $(`#lblKey`).html(KEY);
  $(`#lblAddress`).html(ADDR);
});

$(`#btnRandom`).on(`click`, function (event) {
  genRanBtns(`#lblRandom`, `#lblCorrect`, `#btnCont`);
});

$(`#btnImport`).on(`click`, async function (event) {
  await walletKey($(`#txtImport`).val());
  $(`#lblImport`).html(ADDR);
});

$(`#btnBSC`).on(`click`, async function (event) {
  await walletKey(``, getCookie(`KEY`));
  $(`#lblBSC`).html(await balanceBSC(ADDR));
  $(`#lblWD`).html(await balanceWDT(ADDR));
  $(`#lblPool`).html(await balanceWDT(C_2));
  $(`#txtCheckScore`).html(await getScore(ADDR));
});

$(`#btnScore`).on(`click`, async function (event) {
  $(`#btnScore`).html(
    await updateScore($(`#txtScore`).val(), $(`#txtKey`).val())
  );
});

$(`#btnWithdraw`).on(`click`, async function (event) {
  $(`#btnWithdraw`).html(
    await withdrawal($(`#txtWithdraw`).val(), $(`#txtKey`).val())
  );
});

$(`#btnDefault`).on(`click`, async function (event) {
  setCookie(
    `KEY`,
    `d6e9d2691625bee5e31947d737169209b5dd9a3538b2768e9507d5f9e6eb0660`
  );
  location.href = '/';
});

$(`#btnReset`).on(`click`, async function (event) {
  setCookie(`KEY`, ``);
  location.href = '/';
});

$(document).ready(function () {
  loadCookie();
  if (typeof KEY != 'undefined') $(`#lblDefault`).html(KEY);
});
