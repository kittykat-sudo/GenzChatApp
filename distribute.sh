# !/bin/bash
set -e

# Load .env
export $(grep -v '^#' .env | xargs)

# Clean & build Flutter APK
echo "Building Flutter release APK..."
flutter clean
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

echo "Uploading to Firebase App Distribution..."

# Distribution via Firebase CLI
firebase appdistribution:distribute "$APK_PATH" \
    --app "$FIREBASE_APP_ID" \
    --groups "$FIREBASE_TESTERS"

echo "✅Done! APK uploaded to Firebase App Distribution"