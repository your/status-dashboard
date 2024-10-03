(() => {
  // app/javascript/refresh-on-update.js
  document.addEventListener("turbo:before-stream-render", function() {
    window.location.reload();
  });
})();
