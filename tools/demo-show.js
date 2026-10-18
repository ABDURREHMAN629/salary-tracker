// Runs after the app loads: switch to September 2026 and scroll to the #hash section, if any.
(function () {
  var t = new Date();
  var steps = (t.getFullYear() * 12 + t.getMonth()) - (2026 * 12 + 8);
  var btn = document.getElementById(steps > 0 ? 'prev' : 'next');
  for (var i = 0; i < Math.abs(steps); i++) btn.click();
  if (location.hash) {
    var el = document.querySelector(location.hash);
    if (el) el.scrollIntoView();
  }
})();
