// Sample data for the website screenshots (September 2026, raise on 20 Sep).
// make-images.sh injects this into a copy of app/index.html; it never touches real data.
(function () {
  var ot = { 1: 2, 2: 3, 5: 2, 7: 4, 10: 1.5, 12: 2, 14: 3, 15: 2, 17: 2, 19: 4, 21: 1, 22: 2, 24: 3, 26: 2, 28: 2, 29: 1, 30: 3 };
  var days = {};
  for (var d = 1; d <= 30; d++) {
    if (new Date(2026, 8, d).getDay() === 5) continue; // skip Fridays
    var key = '2026-09-' + (d < 10 ? '0' : '') + d;
    days[key] = d === 8 ? { s: 'A' } : { s: 'P' };
    if (ot[d]) days[key].ot = ot[d];
  }
  localStorage.setItem('salaryTracker.v1', JSON.stringify({
    rates: { cur: 'Rs' },
    rateHistory: [{ from: '', day: 1500, ot: 200 }, { from: '2026-09-20', day: 1600, ot: 220 }],
    days: days
  }));
})();
