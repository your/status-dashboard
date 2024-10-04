// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import { initAll } from "govuk-frontend";

document.addEventListener("turbo:load", function() {
  initAll();
})
