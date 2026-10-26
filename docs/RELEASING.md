# Releasing MacIsland

MacIsland is distributed outside the Mac App Store, so a public download needs to
be signed with a **Developer ID Application** certificate and notarized by
Apple. Without that, Gatekeeper blocks the app on other people's Macs.

The release workflow (`.github/workflows/release.yml`) does everything for you:
builds a universal macOS app, signs it, notarizes it, staples the ticket, and
attaches the zip to a GitHub release.

## 1. Prerequisites

- A paid **Apple Developer Program** membership.
- Account Holder or Admin access to the team.
- The repository's **Settings → Secrets and variables → Actions** page.

The certificate currently used for local Xcode builds
(`Apple Development: ...`) is **not** enough for distribution. You need a
`Developer ID Application` certificate.

## 2. Create the Developer ID certificate

1. Open [developer.apple.com/account](https://developer.apple.com/account) →
   **Certificates, IDs & Profiles** → **Certificates** → **+**.
2. Choose **Developer ID Application** and continue.
3. In **Keychain Access** on your Mac, create a certificate request:
   **Keychain Access → Certificate Assistant → Request a Certificate From a
   Certificate Authority**. Save the `.certSigningRequest` file.
4. Upload the CSR, download the `.cer`, and double-click it to install it in
   your login keychain.
5. In Keychain Access, find **Developer ID Application: ...** under
   **My Certificates**. Select the certificate and its private key, right-click,
   and choose **Export 2 items...**. Save a `.p12` with a strong password.

Verify that the identity is visible:

```bash
security find-identity -v -p codesigning
```

You should see a line containing `Developer ID Application`.

## 3. Create an app-specific password

Notarization uses your Apple ID plus an app-specific password:

1. Go to [appleid.apple.com](https://appleid.apple.com) → **Sign-In and
   Security** → **App-Specific Passwords**.
2. Generate a password for `notarytool` and save it.

## 4. Add the GitHub secrets

In the repository: **Settings → Secrets and variables → Actions → New
repository secret**.

| Secret | Value |
| --- | --- |
| `APPLE_CERTIFICATE_BASE64` | `base64 -i DeveloperID.p12` (copy the whole output) |
| `APPLE_CERTIFICATE_PASSWORD` | The password used when exporting the `.p12` |
| `KEYCHAIN_PASSWORD` | Any random password; used only for the temporary runner keychain |
| `APPLE_ID` | Your Apple ID email |
| `APPLE_APP_SPECIFIC_PASSWORD` | The app-specific password from step 3 |
| `APPLE_TEAM_ID` | Your 10-character Team ID (for this project: `D8Z5GPR44N`) |

To copy the base64 value on macOS:

```bash
base64 -i DeveloperID.p12 | pbcopy
```

Do not commit the `.p12` or the passwords.

## 5. Bump the version

Update `MARKETING_VERSION` in
`MacIsland.xcodeproj/project.pbxproj` and the top entry in `CHANGELOG.md`.
The workflow warns if the Git tag and `CFBundleShortVersionString` do not match.

```text
MARKETING_VERSION = 1.0.1;
```

Commit the change on `main`:

```bash
git add .
git commit -m "Release 1.0.1"
git push origin main
```

## 6. Tag and release

```bash
git tag v1.0.1
git push origin v1.0.1
```

The **Release** workflow runs automatically. It will:

1. Import the Developer ID certificate into a temporary keychain.
2. Build a universal (`arm64` + `x86_64`) Release app.
3. Sign it with the Hardened Runtime and the Apple Events entitlement.
4. Submit it to Apple's notary service and wait for the result.
5. Staple the notarization ticket to the app.
6. Verify the signature and Gatekeeper assessment.
7. Create a GitHub release with `MacIsland-1.0.1.zip`.

Monitor it in **Actions → Release**.

> Tags containing a hyphen (for example `v1.0.1-rc.1`) are published as
> pre-releases.

## 7. Verify the download

On a clean Mac (or after moving the app to `/Applications`):

```bash
spctl --assess --type execute --verbose=4 /Applications/MacIsland.app
codesign --verify --deep --strict --verbose=2 /Applications/MacIsland.app
```

Both commands should succeed. The first launch should show the normal Automation
permission prompt, not a Gatekeeper warning.

## Troubleshooting

- **`No Developer ID Application identity found`** — the `.p12` is wrong, the
  password is wrong, or the certificate is not trusted. Import it into
  Keychain Access and check `security find-identity -v -p codesigning`.
- **Notarization fails** — inspect the log:
  ```bash
  xcrun notarytool log <submission-id> \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_SPECIFIC_PASSWORD" \
    --team-id "$APPLE_TEAM_ID"
  ```
  Common causes: the app was not signed with a secure timestamp, a nested binary
  is unsigned, or `CFBundleShortVersionString` is invalid.
- **Gatekeeper still rejects the app** — make sure you are testing the zip
  produced by the workflow, not a local Xcode build.
- **CI cannot build the project** — the project format requires a recent Xcode.
  The workflow uses `macos-latest`; if the runner's Xcode is too old, use a
  self-hosted runner with Xcode 27+.

## Local release build (optional)

If you want to reproduce the build locally without GitHub Actions:

```bash
xcodebuild \
  -project MacIsland.xcodeproj \
  -scheme MacIsland \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath build \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Developer ID Application" \
  DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  build
```

Then notarize the resulting `build/Build/Products/Release/MacIsland.app` with
`notarytool` and staple it with `stapler`, following the same steps as the
workflow.
