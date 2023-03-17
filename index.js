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
  await walletKey(``, $(`#txtKey`).val());
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