// Fäller ut huvudmenyn på små skärmar. Utan JavaScript ligger menyn
// alltid utfälld (se .ingen-js i style.css), så inget innehåll går förlorat.
(function () {
  var knapp = document.querySelector(".meny-knapp");
  var meny = document.getElementById("huvudmeny");
  if (!knapp || !meny) return;

  knapp.addEventListener("click", function () {
    var oppen = meny.hasAttribute("data-oppen");
    if (oppen) {
      meny.removeAttribute("data-oppen");
    } else {
      meny.setAttribute("data-oppen", "");
    }
    knapp.setAttribute("aria-expanded", String(!oppen));
  });

  // Stäng menyn när skärmen blir bred nog att visa den vågrätt igen.
  var bred = window.matchMedia("(min-width: 55.001rem)");
  bred.addEventListener("change", function (e) {
    if (e.matches) {
      meny.removeAttribute("data-oppen");
      knapp.setAttribute("aria-expanded", "false");
    }
  });
})();
