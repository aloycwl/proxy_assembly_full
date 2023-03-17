$(`#btnGenerate`).on(`click`, async function (event) {
  await walletGenerate();
  await walletKey(MNEMONIC);
  $(`#lblMnemonic`).html(MNEMONIC);
  $(`#lblKey`).html(KEY);
  $(`#lblAddress`).html(ADDR);
  setCookie(`KEY`, KEY);
});

$(`#btnRandom`).on(`click`, function (event) {
  genRanBtns(`#lblRandom`, `#lblCorrect`, `#btnCont`);
});

$(`#btnImport`).on(`click`, async function (event) {
  await walletKey($(`#txtImport`).val());
  setCookie(`KEY`, KEY);
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
  $(`#btnScore`).html(await updateScore($(`#txtScore`).val(), KEY));
});

$(`#btnWithdraw`).on(`click`, async function (event) {
  $(`#btnWithdraw`).html(await withdrawal($(`#txtWithdraw`).val(), KEY));
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

loadCookie();
if (typeof KEY != 'undefined') $(`#lblDefault`).html(KEY);

async function encryptData(data) {
  const encoder = new TextEncoder();
  const key = await window.crypto.subtle.generateKey(
    {name: 'AES-GCM', length: 256},
    true,
    ['encrypt', 'decrypt']
  );
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  const encryptedData = await window.crypto.subtle.encrypt(
    {name: 'AES-GCM', iv},
    key,
    encoder.encode(data)
  );
  return {encryptedData, key, iv};
}