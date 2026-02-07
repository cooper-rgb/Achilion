HealthKit integration & migration notes
=====================================

Purpose
-------
This document explains how we handle HealthKit during local development (using Personal Teams) and how to migrate to a paid Apple Developer Program to enable real HealthKit functionality and shared provisioning.

What we changed in A2
---------------------
- `.gitignore` updated to ignore any real `GoogleService-Info*.plist` files while whitelisting the dev placeholder `Config/GoogleService-Info-Dev.plist`.
- `Config/GoogleService-Info-Dev.plist` contains a harmless placeholder (no real API keys). CI is configured to accept a base64-encoded real dev plist via the `GOOGLE_SERVICE_INFO_DEV_BASE64` secret.
- `App/Achilion/Achilion.entitlements` already contains `com.apple.developer.healthkit` (true). That means the project references the entitlement file; enabling HealthKit in the Apple Developer portal is still required for it to be active on devices.

Important note about `Info.plist`
---------------------------------
We attempted to automate insertion of HealthKit usage strings into `App/Achilion/Info.plist` in this session. If you don't see the following keys in the file, run the verification and fix commands below (it’s easy to apply locally):

- `NSHealthShareUsageDescription` — user-facing rationale for reading health data
- `NSHealthUpdateUsageDescription` — user-facing rationale for writing health data
- `UIBackgroundModes` includes `fetch` (we recommend to keep `remote-notification` too)

Why placeholder plists are safe
------------------------------
- The tracked `Config/GoogleService-Info-Dev.plist` is a harmless placeholder with no valid API keys — it will not connect to production Firebase or leak credentials.
- CI uses a secret (`GOOGLE_SERVICE_INFO_DEV_BASE64`) to write the real dev plist at runtime, so you do not need to commit sensitive files to the repo.
- When you're ready to use the real dev plist locally, put the real `GoogleService-Info-Dev.plist` in `Config/` on your machine (it’s ignored from being committed by .gitignore rules), or set up the CI secret for shared builds.

How to finish HealthKit locally (commands to run)
------------------------------------------------
If `App/Achilion/Info.plist` is missing the HealthKit keys, run this one-shot command locally to insert them (works on macOS bash/zsh):

```bash
# backup first
cp App/Achilion/Info.plist App/Achilion/Info.plist.bak

python3 - <<'PY'
from xml.etree import ElementTree as ET
p='App/Achilion/Info.plist'
try:
    tree=ET.parse(p)
    root=tree.getroot()
    d=root.find('dict')
    def has_key(k):
        for el in d:
            if el.tag=='key' and el.text==k:
                return True
        return False
    def insert_after(key_text, new_key, new_string):
        # naive append at end
        ET.SubElement(d,'key').text=new_key
        ET.SubElement(d,'string').text=new_string

    if not has_key('NSHealthShareUsageDescription'):
        insert_after(None,'NSHealthShareUsageDescription','Allow Achilion to read health data to provide personalized plans and progress tracking.')
    if not has_key('NSHealthUpdateUsageDescription'):
        insert_after(None,'NSHealthUpdateUsageDescription','Allow Achilion to write health data for tracking and syncing progress with your plans.')

    # Ensure UIBackgroundModes exists and contains 'fetch'
    found=False
    elems=list(d)
    for i,el in enumerate(elems):
        if el.tag=='key' and el.text=='UIBackgroundModes':
            arr=elems[i+1]
            if arr.tag=='array':
                has_fetch=False
                for child in arr:
                    if child.tag=='string' and child.text=='fetch':
                        has_fetch=True
                if not has_fetch:
                    ET.SubElement(arr,'string').text='fetch'
                found=True
                break
    if not found:
        ET.SubElement(d,'key').text='UIBackgroundModes'
        arr=ET.SubElement(d,'array')
        ET.SubElement(arr,'string').text='fetch'
        ET.SubElement(arr,'string').text='remote-notification'

    ET.indent(tree, space='\t')
    tree.write(p, encoding='utf-8', xml_declaration=True)
    print('Info.plist updated')
except Exception as e:
    print('Error updating Info.plist:', e)
PY
```

Verification commands
---------------------
Run these to confirm everything is in place:

```bash
# Check Info.plist keys
plutil -p App/Achilion/Info.plist | egrep 'NSHealthShareUsageDescription|NSHealthUpdateUsageDescription' || echo 'Health usage keys missing'

# Check entitlements include healthkit
plutil -p App/Achilion/Achilion.entitlements | egrep 'com.apple.developer.healthkit' || echo 'HealthKit entitlement missing'

# Confirm dev placeholder exists
ls -l Config/GoogleService-Info-Dev.plist && cat Config/GoogleService-Info-Dev.plist | sed -n '1,80p'

# Show build settings referencing entitlements
xcodebuild -project Achilion.xcodeproj -scheme Achilion -showBuildSettings | egrep 'CODE_SIGN_ENTITLEMENTS|INFOPLIST_FILE|DEVELOPMENT_TEAM' -n

# Local build (simulator)
xcodebuild -project Achilion.xcodeproj -scheme Achilion -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' clean build 2>&1 | tee build.log
egrep -n "error:" build.log | sed -n '1,200p'
```

Migration to paid Apple Developer Program
----------------------------------------
When ready to enable HealthKit on devices and share a unified App ID/provisioning:

1. Buy/upgrade to an Organization Apple Developer Program account (or use an existing org account).
2. Invite teammates’ Apple IDs to your Developer Team and have them accept.
3. In developer.apple.com → Identifiers → select your App ID → enable HealthKit capability and save.
4. Regenerate provisioning profiles (or let Xcode automatic signing refresh them).
5. Test on device; the entitlement will be active and HealthKit APIs will operate normally.

CI notes
--------
- Add the real dev plist to GitHub Secrets as `GOOGLE_SERVICE_INFO_DEV_BASE64`:

```bash
base64 Config/GoogleService-Info-Dev.plist | pbcopy
# paste into GitHub secret: GOOGLE_SERVICE_INFO_DEV_BASE64
```

- The CI workflow `.github/workflows/ci.yml` decodes that secret and writes the real `Config/GoogleService-Info-Dev.plist` at runtime before the build step.

Questions or next actions
-------------------------
- I can add a `MockHealthKitManager` now in `App/Services/` so UI can be built and PlanGenerator can consume synthetic data. Should I add that next?
- If you want, I can also create a PR branch with these docs and any Info.plist edits you prefer me to apply directly.
