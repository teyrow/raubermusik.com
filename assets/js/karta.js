// Google Maps sätter cookies och registrerar besökaren så snart kartan laddas.
// Därför laddas den först när besökaren själv klickar.
(function () {
  var ruta = document.querySelector(".karta");
  if (!ruta) return;
  var knapp = ruta.querySelector("[data-ladda-karta]");
  if (!knapp) return;

  knapp.addEventListener("click", function () {
    var ram = document.createElement("iframe");
    ram.src = ruta.getAttribute("data-src");
    ram.title = "Karta över Nygatan 20, Motala";
    ram.loading = "lazy";
    ram.referrerPolicy = "no-referrer-when-downgrade";
    ram.allowFullscreen = true;
    ruta.innerHTML = "";
    ruta.appendChild(ram);
  });
})();
