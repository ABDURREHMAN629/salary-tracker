#!/usr/bin/env bash
# Builds build/salary-tracker.apk from ../index.html using the Android SDK
# build-tools and Android Studio's bundled JDK (no Gradle needed).
#
#   bash android/build.sh            build the APK
#   bash android/build.sh install    build, then install on the USB-connected phone
set -euo pipefail
cd "$(dirname "$0")"

SDK="$(cygpath -u "${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}")"
BT="$SDK/build-tools/36.0.0"
ANDROID_JAR="$SDK/platforms/android-37.0/android.jar"
JBR="/c/Program Files/Android/Android Studio/jbr/bin"
ADB="$SDK/platform-tools/adb.exe"

VERSION_CODE="$(date +%y%m%d%H)"   # grows with each build so updates install over the old app
VERSION_NAME="1.0"

# Signing key: created once, kept outside git. Keep it — updates must be signed with the same key.
if [ ! -f salary.keystore ]; then
  echo "Creating signing key..."
  KS_PASS="$(head -c 24 /dev/urandom | base64 | tr -dc 'A-Za-z0-9')"
  echo "KS_PASS=$KS_PASS" > keystore.properties
  "$JBR/keytool.exe" -genkeypair -keystore salary.keystore -storepass "$KS_PASS" -keypass "$KS_PASS" \
    -alias salary -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Salary Tracker" -noprompt
fi
# shellcheck disable=SC1091
source keystore.properties
export KS_PASS

echo "Compiling resources..."
rm -rf build
mkdir -p build/assets build/classes build/gen build/dex
cp ../index.html build/assets/index.html
"$BT/aapt2.exe" compile --dir res -o build/res.zip
"$BT/aapt2.exe" link -o build/base.apk -I "$ANDROID_JAR" --manifest AndroidManifest.xml \
  -A build/assets --java build/gen --min-sdk-version 26 --target-sdk-version 34 \
  --version-code "$VERSION_CODE" --version-name "$VERSION_NAME" build/res.zip

echo "Compiling Java..."
"$JBR/javac.exe" --release 17 -nowarn -classpath "$ANDROID_JAR" -d build/classes \
  $(find src build/gen -name '*.java')
"$JBR/java.exe" -cp "$BT/lib/d8.jar" com.android.tools.r8.D8 --release --min-api 26 \
  --lib "$ANDROID_JAR" --output build/dex $(find build/classes -name '*.class')

echo "Packaging and signing..."
cp build/base.apk build/unaligned.apk
(cd build/dex && "$JBR/jar.exe" uf ../unaligned.apk classes.dex)
"$BT/zipalign.exe" -f -p 4 build/unaligned.apk build/aligned.apk
"$JBR/java.exe" -jar "$BT/lib/apksigner.jar" sign --ks salary.keystore --ks-pass env:KS_PASS \
  --out build/salary-tracker.apk build/aligned.apk
echo "Built android/build/salary-tracker.apk (version $VERSION_NAME, code $VERSION_CODE)"

if [ "${1:-}" = "install" ]; then
  echo "Installing on phone..."
  "$ADB" install -r build/salary-tracker.apk
fi
