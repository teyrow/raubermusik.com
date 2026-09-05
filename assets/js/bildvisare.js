// Bildvisare för gallerier. Varje bild ligger i en vanlig länk till
// fullstorleksbilden, så utan JavaScript öppnas bilden som vanligt –
// med JavaScript fångas klicket och bilden visas i en overlay i stället.
(function () {
  var lankar = Array.prototype.slice.call(document.querySelectorAll("a[data-galleri]"));
  if (!lankar.length || !window.HTMLDialogElement) return;

  var index = 0;
  var oppnare = null;

  var dialog = document.createElement("dialog");
  dialog.className = "bildvisare";
  dialog.setAttribute("aria-label", "Bildvisare");
  dialog.innerHTML =
    '<button class="bildvisare__stang" type="button" aria-label="Stäng">&times;</button>' +
    '<button class="bildvisare__pil bildvisare__pil--bak" type="button" aria-label="Föregående bild">&#8249;</button>' +
    '<figure class="bildvisare__ruta">' +
    '  <img class="bildvisare__bild" alt="">' +
    '  <figcaption class="bildvisare__text"><span data-text></span> <span class="bildvisare__raknare" data-raknare></span></figcaption>' +
    '</figure>' +
    '<button class="bildvisare__pil bildvisare__pil--fram" type="button" aria-label="Nästa bild">&#8250;</button>';
  document.body.appendChild(dialog);

  var bild = dialog.querySelector(".bildvisare__bild");
  var text = dialog.querySelector("[data-text]");
  var raknare = dialog.querySelector("[data-raknare]");

  function visa(i) {
    index = (i + lankar.length) % lankar.length;
    var lank = lankar[index];
    var bildtext = lank.getAttribute("data-bildtext") || "";
    bild.src = lank.href;
    bild.alt = bildtext;
    text.textContent = bildtext;
    raknare.textContent = (index + 1) + " / " + lankar.length;
    forladda(index + 1);
    forladda(index - 1);
  }

  function forladda(i) {
    var lank = lankar[(i + lankar.length) % lankar.length];
    if (lank) new Image().src = lank.href;
  }

  function oppna(i, fran) {
    oppnare = fran;
    visa(i);
    dialog.showModal();
  }

  lankar.forEach(function (lank, i) {
    lank.addEventListener("click", function (e) {
      // Låt mellanklick och ctrl/cmd-klick öppna bilden i ny flik som vanligt.
      if (e.metaKey || e.ctrlKey || e.shiftKey || e.button !== 0) return;
      e.preventDefault();
      oppna(i, lank);
    });
  });

  dialog.querySelector(".bildvisare__stang").addEventListener("click", function () { dialog.close(); });
  dialog.querySelector(".bildvisare__pil--bak").addEventListener("click", function () { visa(index - 1); });
  dialog.querySelector(".bildvisare__pil--fram").addEventListener("click", function () { visa(index + 1); });

  dialog.addEventListener("keydown", function (e) {
    if (e.key === "ArrowLeft") { e.preventDefault(); visa(index - 1); }
    if (e.key === "ArrowRight") { e.preventDefault(); visa(index + 1); }
  });

  // Klick utanför bilden stänger.
  dialog.addEventListener("click", function (e) {
    if (e.target === dialog) dialog.close();
  });

  // Esc hanteras av <dialog> själv – se bara till att fokus kommer tillbaka.
  dialog.addEventListener("close", function () {
    if (oppnare) oppnare.focus();
  });
})();
