CI Guide
========

Overview
--------
This project uses GitHub Actions to build the iOS app and run unit tests on macOS runners. The CI workflow is defined in `.github/workflows/ci.yml` and runs on PRs and pushes to `main`/`master`.

Secrets and GoogleService-Info
-----------------------------
- For local development, add `Config/GoogleService-Info-Dev.plist` manually (do not commit production plists).
- For CI, store the Base64-encoded development plist in GitHub secrets as `GOOGLE_SERVICE_INFO_DEV_BASE64`.
  - To create the secret value locally:

```bash
base64 Config/GoogleService-Info-Dev.plist | pbcopy
# paste into GitHub secret: GOOGLE_SERVICE_INFO_DEV_BASE64
```

Xcode & macOS versions
-----------------------
- CI uses `macos-latest`. Ensure your local Xcode version matches CI's runtime (check `xcodebuild -version`).

Running CI steps locally
------------------------
You can run the build commands locally to reproduce CI:

```bash
# build for simulator
xcodebuild -project Achilion.xcodeproj -scheme Achilion -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' clean build

# run tests
xcodebuild test -project Achilion.xcodeproj -scheme Achilion -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest'
```

Linting (optional)
------------------
- The CI runs a `lint` job using `swiftlint` if available on the runner. To run SwiftLint locally:

```bash
brew install swiftlint
swiftlint lint
```

Troubleshooting
---------------
- If CI fails with `xcodebuild: requires Xcode`, ensure Xcode is installed and `xcode-select -p` points to `/Applications/Xcode.app/Contents/Developer`.
- If tests hang on the simulator in CI, try using a more specific simulator runtime or run tests on a local machine for debugging.
