# Secrets & Cross-Repo Access

This file is the **single canonical reference** for every secret
consumed by the AmericanGroupLLC release pipelines, and the steps
required to enable the umbrella repo's reusable workflows for the
other repos in this org.

> Workflows degrade gracefully when any optional secret is absent.
> The release will still publish whatever it could build.

---

## 0. One-time org-level setting (REQUIRED for shared workflows)

The reusable workflows in this repo are referenced by every product
repo as:

```yaml
uses: AmericanGroupLLC/AmericanGroupLLC/.github/workflows/release-book.yml@main
```

For GitHub Actions to allow this cross-repo `uses:`, the umbrella
repo must explicitly grant access:

1. Open <https://github.com/AmericanGroupLLC/AmericanGroupLLC/settings/actions>
2. Under **Access**, select  
   **"Accessible from repositories owned by the user 'AmericanGroupLLC'"**
3. Save.

Until this is set, the product repos' `release-book` and
`release-video` jobs will fail with `error: workflow not found`.

---

## 1. GitHub-managed (always available, no setup)

| Secret              | Used by                | Notes                          |
|---------------------|------------------------|--------------------------------|
| `GITHUB_TOKEN`      | every workflow         | Auto-injected by GitHub        |

---

## 2. Android signing (per product repo)

Set on each product repo at  
*Settings → Secrets and variables → Actions*:

| Secret                          | Required | Purpose                        |
|---------------------------------|:-:|----------------------------------------|
| `ANDROID_KEYSTORE_BASE64`       | optional | Base64-encoded `upload.jks` |
| `ANDROID_KEYSTORE_PASSWORD`     | optional | Keystore password           |
| `ANDROID_KEY_ALIAS`             | optional | Key alias                   |
| `ANDROID_KEY_PASSWORD`          | optional | Key password                |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | optional | Google Play upload         |
| `PLAY_STORE_PACKAGE_NAME`       | optional | Play Console package name   |

When absent: the build still runs; APKs are produced unsigned and
the Play upload step is skipped.

---

## 3. iOS signing (per product repo)

For a real `.ipa` (not a Simulator `.app.zip`):

| Secret                                | Required | Purpose                  |
|---------------------------------------|:-:|----------------------------------|
| `APPLE_CERTIFICATE_BASE64`            | optional | Base64-encoded `.p12`    |
| `APPLE_CERTIFICATE_PASSWORD`          | optional | `.p12` password          |
| `APPLE_KEYCHAIN_PASSWORD`             | optional | Temp keychain password (any string) |
| `APPLE_PROVISIONING_PROFILE_BASE64`   | optional | Base64-encoded `.mobileprovision` (wildcard recommended for repos with extensions) |
| `APPLE_TEAM_ID`                       | optional | 10-char team ID          |
| `APPLE_BUNDLE_ID`                     | optional | Override `release.config.json.bundleId` |
| `APP_STORE_CONNECT_API_KEY_ID`        | optional | TestFlight upload        |
| `APP_STORE_CONNECT_API_ISSUER_ID`     | optional | TestFlight upload        |
| `APP_STORE_CONNECT_API_KEY_P8_BASE64` | optional | TestFlight upload        |
| `MATCH_PASSWORD`                      | optional | Fastlane Match           |
| `MATCH_GIT_URL`                       | optional | Fastlane Match repo URL  |

When absent: the iOS job falls back to producing the existing
unsigned **Simulator** `.app.zip`.

---

## 4. Telemetry (optional, per product repo)

| Secret                       | Used by                       |
|------------------------------|-------------------------------|
| `SENTRY_DSN_ANDROID`         | Android release builds        |
| `SENTRY_DSN_IOS`             | iOS / watchOS release builds  |
| `SENTRY_DSN_WEAR`            | Wear OS release builds        |
| `POSTHOG_API_KEY_ANDROID`    | Android telemetry             |
| `POSTHOG_API_KEY_IOS`        | iOS telemetry                 |
| `POSTHOG_HOST`               | PostHog ingestion endpoint    |

---

## 5. Backend (DriftDate, HealthApp)

| Secret                  | Used by                              |
|-------------------------|--------------------------------------|
| `SUPABASE_URL`          | `backend/` Node service deploy       |
| `SUPABASE_ANON_KEY`     | Backend deploy + smoke tests         |
| `SUPABASE_SERVICE_KEY`  | Backend admin tasks                  |

---

## 6. Umbrella dashboard (this repo)

| Secret           | Required | Purpose                                |
|------------------|:-:|------------------------------------------------|
| `DASHBOARD_PAT`  | optional | PAT with `repo` scope to read each child repo's `releases/latest`. Falls back to `GITHUB_TOKEN`, which can only see public releases of repos in this org. |

---

## 7. Verifying a repo has the secrets it needs

Run, in any product repo:

```bash
bash scripts/verify-release-config.sh
```

It prints which optional features are enabled by which secret, so
you can plan store submissions without surprise CI failures.
