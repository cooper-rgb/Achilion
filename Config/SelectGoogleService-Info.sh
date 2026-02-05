#!/bin/sh
# Copy the environment-specific GoogleService-Info plist into the app bundle so Firebase finds it.
# Safe for app targets and handles typical Xcode resource locations.

set -e

echo "=== SelectGoogleService-Info.sh ==="
echo "APP_ENV: ${APP_ENV}"
echo "GOOGLE_SERVICE_INFO_PLIST: ${GOOGLE_SERVICE_INFO_PLIST}"
echo "PROJECT_DIR: ${PROJECT_DIR}"
echo "TARGET_NAME: ${TARGET_NAME}"

if [ -z "${GOOGLE_SERVICE_INFO_PLIST}" ]; then
  echo "No GOOGLE_SERVICE_INFO_PLIST set. Skipping GoogleService-Info copy."
  exit 0
fi

SRC="${PROJECT_DIR}/Config/${GOOGLE_SERVICE_INFO_PLIST}"

# Prefer the unlocalized resources folder path (works for app bundles)
if [ -n "${TARGET_BUILD_DIR}" ] && [ -n "${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
  DEST="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"
else
  # Fallback (older Xcode / uncommon targets)
  DEST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi

if [ -f "${SRC}" ]; then
  echo "Copying ${SRC} -> ${DEST}"
  /bin/cp "${SRC}" "${DEST}"
  /usr/bin/ls -l "${DEST}" || true
  echo "Copy complete"
else
  echo "Warning: ${SRC} not found. Make sure the plist exists in Config/ or update your xcconfig."
  # Don't fail the build for missing prod plist in local dev; CI should provide prod file for Archive
  exit 0
fi
