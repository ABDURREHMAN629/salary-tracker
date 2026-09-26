# AR Salary Tracker

**Developed by AR** · Contact: [+92 324 7440629](tel:+923247440629) · [WhatsApp](https://wa.me/923247440629)

A simple app to track daily salary and overtime, with totals for each 15-day period (1–15 and 16–end of month) and the full month.

## Download (Android)

**[Download AR-Salary-Tracker.apk](https://github.com/ABDURREHMAN629/salary-tracker/releases/latest/download/AR-Salary-Tracker.apk)** (Android 8 or newer)

Open the file on your phone and tap **Install**. If the phone asks, allow installing from this source. If Play Protect warns about an unknown app, tap **More details → Install anyway** (the app is not on the Play Store).

## How to use

Open `index.html` in any browser, or install the Android app (below). No internet needed.

1. Enter your **salary per day**, **overtime per hour** and **currency** once at the top.
2. Tap **P** on days you worked to add that day's salary (**A** = absent, tap again to clear).
3. Type **overtime hours** for a day to add overtime pay.
4. Fridays are shown in red (usual leave day).
5. When your rate changes, type the new rate at the top and pick the date it starts. Earlier days keep the old rate.

Data is saved on the device. Use **Download backup** / **Restore backup** at the bottom to keep a copy.

## Building the Android app

`android/` wraps the same page in an Android app. With Android Studio installed and a phone connected by USB (USB debugging on):

```bash
bash android/build.sh install
```

The first build creates `android/salary.keystore` (not in git). Keep it: updates must be signed with the same key, or the phone makes you uninstall first, which erases the app's data.
