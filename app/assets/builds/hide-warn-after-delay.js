(() => {
  // app/javascript/hide-warn-after-delay.js
  document.addEventListener("turbo:load", function() {
    setTimeout(function() {
      var element = document.querySelector(".govuk-warning-text");
      if (element && !element.textContent.includes("error")) {
        element.style.display = "none";
      }
    }, 3500);
  });
})();
