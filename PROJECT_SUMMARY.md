# AR Salary Tracker: Project Summary & Handoff Notes

Read this first if you are continuing this project later, on another computer, or from another account (person or AI assistant). It explains what exists, how it works, and how to do every common task.

Last updated: 18 Oct 2026 · Current app version: **1.1**

---

## 1. What this project is

**AR Salary Tracker** is a free app for factory and daily-wage workers. A worker enters their **salary per day** and **overtime rate per hour** once, then for each day taps **P** (present) or **A** (absent) and types overtime hours. The app shows totals for **1–15**, **16–end of month**, and the **full month**. Fridays are shown in red (usual day off). When the wage changes, the new rate starts from a chosen date and old days keep the old rate.

It is one HTML file (`app/index.html`) that runs:
- as an **Android app** (APK) that wraps the page in a WebView, and
- **online** in any browser (GitHub Pages), for iPhone and computers.

There is also a bilingual (English + Urdu) **website / landing page** (`index.html`) made for search engines and Facebook sharing.

## 2. Links

| What | Link |
| --- | --- |
| GitHub repo (public) | https://github.com/ABDURREHMAN629/salary-tracker |
| Website (GitHub Pages) | https://abdurrehman629.github.io/salary-tracker/ |
| Online app | https://abdurrehman629.github.io/salary-tracker/app/ |
| **APK download (always the newest)** | https://github.com/ABDURREHMAN629/salary-tracker/releases/latest/download/AR-Salary-Tracker.apk |
| Releases page | https://github.com/ABDURREHMAN629/salary-tracker/releases |

## 3. Developer & contact (public)

- Brand / developer name: **AR** (shown as "Developed by AR")
- Phone / WhatsApp: **+92 324 7440629**
- Email: **gabdurehman493@gmail.com**

**Privacy rule:** only the brand "AR", the phone number and this Gmail are public. Do **not** add the developer's full name, personal email, address, or computer file paths to any file, commit message, website or post. Git commits in this folder are made as author **"AR"** (set with `git config user.name "AR"` in this repo) with the GitHub no-reply email.

## 4. Folder structure

| Path | What it is |
| --- | --- |
| `app/index.html` | **The app.** Single file: HTML + CSS + JavaScript. No build step, no libraries. |
| `index.html` | Website / landing page (SEO meta tags, Open Graph preview, JSON-LD `SoftwareApplication` + `FAQPage`, English + Urdu). |
| `AR-Salary-Tracker.apk` | Latest APK (same file as the newest GitHub release). |
| `android/` | Android wrapper project (built without Gradle). |
| `android/build.sh` | Builds the APK; `install` argument also installs it on a USB-connected phone. |
| `android/src/.../MainActivity.java` | WebView + JavaScript bridge (`window.AndroidApp`) + backup file save/open + external links. |
| `android/res/` | App name, themes (light/dark), adaptive icon (vector). |
| `assets/` | `logo.svg`, `icon-512.png`, `screenshot-summary.png`, `screenshot-days.png`, `og-image.png` (1200×630 link preview). |
| `tools/make-images.sh` | Regenerates everything in `assets/*.png` with headless Chrome/Edge using sample data. |
| `tools/demo-data.js`, `tools/demo-show.js`, `tools/og-image.html` | Inputs for `make-images.sh`. |
| `sitemap.xml`, `.nojekyll` | For GitHub Pages / Google. |
| `README.md` | Public GitHub front page (SEO keywords, download links, Urdu section, FAQ, contact). |
| `CLAUDE.md` | Short rules for AI assistants; points here. |

**Local only (in `.gitignore`, never on GitHub):**
- `android/salary.keystore` and `android/keystore.properties`: the **APK signing key** and its password. See section 7.
- `android/build/`: temporary build output.

## 5. How the app works (technical)

**Saved data:** one JSON object.
- In a browser it is in `localStorage` under the key `salaryTracker.v1`.
- In the Android app it is in SharedPreferences (file `salary`, key `data`), through `window.AndroidApp.load()` and `window.AndroidApp.store(json)`.

```json
{
  "rates": { "cur": "Rs" },
  "rateHistory": [
    { "from": "", "day": 2000, "ot": 262 },
    { "from": "2026-09-20", "day": 2500, "ot": 300 }
  ],
  "days": {
    "2026-09-01": { "s": "P", "ot": 4 },
    "2026-09-03": { "s": "A" }
  }
}
```

- `rateHistory` is sorted by `from` date. The first entry always has `from: ""` and covers all days before the next entry. Each day is paid with the rate whose `from` is the latest date ≤ that day (`rateFor()`).
- Day pay = (`s` is `"P"` ? day rate : 0) + `ot` hours × overtime rate.
- Older saves had `rates.day` / `rates.ot` (one rate for all days). `normalize()` converts them automatically, so never remove that code.
- Rate input behaviour: before any day is marked, typing a rate saves it directly. After that, changing a rate shows a "New rate? Starts from [date]" box with three choices:
  - **Save new rate:** adds a history entry starting on that date.
  - **Fix the rate for all days:** corrects the current entry instead.
  - **Cancel:** puts back the saved rate.
- Backups:
  - In a browser, they download as a JSON file and restore through a file picker.
  - In the Android app, `AndroidApp.saveBackup(json, name)` opens the system "Save as" screen, and the file picker opens the system file chooser.
- Links in the Android app: `tel:`, WhatsApp (`https://wa.me/...`) and `mailto:` open the dialer, WhatsApp or an email app.
- The app has **no Android permissions** and no INTERNET permission.

**Android app facts:**
- **Package ID: `com.abdurrehman.salarytracker`. Never change it.** A new ID becomes a different app: people can't update, and they lose their data.
- minSdk 26 (Android 8), targetSdk 34, compiled against the android-37 platform.
- versionCode is automatic (`yyMMddHH`), so each build is newer. versionName is set in `android/build.sh` (`VERSION_NAME`).

## 6. Common tasks

### Requirements (Windows)
- **Git Bash** (to run the `.sh` scripts), **GitHub CLI** `gh` logged in to the `ABDURREHMAN629` account.
- **Android Studio**, which provides the SDK in `%LOCALAPPDATA%\Android\Sdk` (build-tools **36.0.0**, platform **android-37.0**, platform-tools `adb`) and Java in `C:\Program Files\Android\Android Studio\jbr`. If versions change, edit the paths at the top of `android/build.sh`.
- **Google Chrome** or Microsoft Edge, only for `tools/make-images.sh`.

### Change the app
Edit `app/index.html`. To test, open it in a browser (double-click). Data you enter there is saved in that browser only.

### Build the APK / install on a phone
```bash
bash android/build.sh            # builds android/build/salary-tracker.apk
bash android/build.sh install    # builds and installs on the USB-connected phone
```
Phone setup:
1. Turn on **Developer options**: go to Settings → About phone and tap **Build number** (or **MIUI version**) 7 times.
2. Turn on **USB debugging**. On Xiaomi/Redmi phones, also turn on **Install via USB**.
3. Connect the cable in **File transfer** mode and tap **Allow** on the "Allow USB debugging?" prompt.

To check the connection, run `adb devices` (adb is in `%LOCALAPPDATA%\Android\Sdk\platform-tools`). If it shows `offline`, run `adb reconnect offline`.

### Publish a new version (the APK download link updates by itself)
1. Raise `VERSION_NAME` in `android/build.sh` (e.g. `1.2`) and `"softwareVersion"` in `index.html`.
2. `bash android/build.sh`
3. `cp android/build/salary-tracker.apk AR-Salary-Tracker.apk`
4. Commit and push: `git add -A && git commit -m "..." && git push`
5. Create the release. The file name must stay `AR-Salary-Tracker.apk`, or the "latest" link breaks.
   ```bash
   gh release create v1.2 AR-Salary-Tracker.apk --title "AR Salary Tracker v1.2" --notes "What changed..."
   ```
6. On phones, people download from the same link and install over the old app. Their data stays.

### Update the website
Edit `index.html` (and `sitemap.xml` `lastmod`), then commit and push. GitHub Pages republishes within about a minute (it serves the `main` branch, root folder).

### Regenerate screenshots / preview image
```bash
bash tools/make-images.sh
```
- It uses sample data (September 2026, a raise on 20 Sep) and never touches real data.
- Gotcha: Chrome/Edge windows can't be narrower than about 500px, so the app is rendered inside a 412px iframe.
- Gotcha: if Edge is in the middle of updating, its headless mode silently produces no file. The script prefers Chrome for this reason.

## 7. ⚠️ The signing key (very important)

`android/salary.keystore` and `android/keystore.properties` (its password) exist **only on the developer's computer**. They are not in git, on purpose: anyone with them could publish fake updates.

- Every update must be signed with this **same key**. With a different key, phones refuse the update, and people must uninstall (which **deletes their data**) and reinstall.
- **Back up both files** somewhere safe and private, such as a USB drive or a private Google Drive folder. Never put them in a public place.
- If they are lost: `android/build.sh` will create a new key automatically. That works for new installs, but existing users must uninstall first (tell them to use **Download backup** first and **Restore backup** after).

## 8. History

| Date | What was done |
| --- | --- |
| 26 Sep 2026 | Built the single-file web app (P/A attendance, overtime, 15-day + monthly totals, Fridays red, localStorage, backup/restore). Created the GitHub repo. |
| 26 Sep 2026 | Built the Android app without Gradle and installed it on the developer's phone over USB. Renamed it **AR Salary Tracker**, added "Developed by AR", made the new colourful icon, added the phone/WhatsApp contact card. |
| 26 Sep 2026 | Added **rate history** (a salary increase no longer changes old days). Made the repo public. Released **v1.0** with the APK. |
| 14–18 Oct 2026 | Added the SEO website (English + Urdu, Open Graph image, JSON-LD, FAQ, sitemap) on GitHub Pages and moved the app to `app/`. Rewrote the README for search. Added repo description and topics. Added the Gmail contact. Removed unneeded code comments. Wrote this summary. Released **v1.1**. |

## 9. Ideas / next steps (not done yet)

- **Google Search Console:** add the website, verify it, and submit `sitemap.xml` so Google indexes it faster.
- **GitHub social preview:** in repo Settings → General → Social preview, upload `assets/og-image.png`. This can only be done in the browser.
- **Privacy:** the GitHub username `ABDURREHMAN629` and the profile display name are visible on GitHub. To hide the full name, change the profile name in GitHub Settings → Profile. Renaming the username would change all links.
- Possible features: Urdu language for the app itself, half-day attendance, a monthly PDF/print summary, publishing on Google Play.

## 10. Facebook promo post (ready to paste)

Share the **website link**, because it shows a nice preview image on Facebook/WhatsApp. If a group blocks links, share the APK link.

```
📱 AR سیلری ٹریکر: دیہاڑی دار مزدوروں کے لیے مفت ایپ

کیا آپ فیکٹری میں دیہاڑی پر کام کرتے ہیں؟ اپنی تنخواہ اور اوور ٹائم کا حساب خود رکھیں، تاکہ آپ کو ہمیشہ پتہ ہو کہ آپ کے کتنے پیسے بنتے ہیں۔

✅ جس دن کام پر جائیں، P دبائیں
⏱️ اوور ٹائم کے گھنٹے لکھیں
💰 ہر 15 دن اور پورے مہینے کا حساب خود بخود
📅 جمعہ کا دن سرخ رنگ میں
📈 دیہاڑی بڑھ گئی؟ پرانے دنوں کا حساب پرانے ریٹ پر ہی رہے گا
🔒 انٹرنیٹ کی ضرورت نہیں، آپ کا ڈیٹا صرف آپ کے فون میں رہتا ہے

📥 مفت ڈاؤن لوڈ کریں (اینڈرائیڈ):
https://abdurrehman629.github.io/salary-tracker/

👨‍💻 ڈیویلپر: AR
📞 کال / واٹس ایپ: +92 324 7440629
✉️ ای میل: gabdurehman493@gmail.com

━━━━━━━━━━━━━━

📱 AR Salary Tracker: a free app for daily-wage workers

Do you work in a factory on daily wages? Keep your own record of your salary and overtime, so you always know exactly how much you've earned.

✅ Tap P for every day you work
⏱️ Enter your overtime hours
💰 Automatic totals for every 15 days and the full month
📅 Fridays shown in red
📈 Got a raise? Old days stay at the old rate
🔒 No internet needed, and your data stays only on your phone

📥 Free download (Android):
https://abdurrehman629.github.io/salary-tracker/

👨‍💻 Developed by AR
📞 Call / WhatsApp: +92 324 7440629
✉️ Email: gabdurehman493@gmail.com
```
