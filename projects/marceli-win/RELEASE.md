# Marceli Win — desktop release engineering

_Status: **installer release candidate**, not yet a public trusted stable release._

## What is built

Marceli Win remains a Windows PowerShell 5.1 / WPF desktop application; packaging it with NSIS creates a **real installer executable**, not a compiled .NET replacement for the PowerShell application. The installer:

- installs under `%LOCALAPPDATA%\Programs\MarceliWin` for the current Windows user (no administrator access requested during installation);
- creates Start Menu shortcuts for launch and uninstall;
- bundles a manual `Check-Update.ps1` and `Test-ReleaseIntegrity.ps1` verifier in the installation directory and portable ZIP, requiring an independently pinned publisher identity before trusting a newer release;
- registers under Windows Apps & Features (HKCU uninstall entry);
- does not modify PowerShell execution policy, Defender, Windows Update, UAC, or Windows services;
- preserves the user's local log and registry rollback history at `%LOCALAPPDATA%\MarceliWin` on uninstall;
- is exercised by automated **silent installation, file checksum, shortcuts, registration, uninstall, and preservation tests** on a disposable Windows GitHub Actions runner.

For the portable build, the ZIP contains the independently reviewable `MarceliWin.ps1`, `launcher.cmd`, MIT licence and install notes. The standalone launcher remains available from `https://win.marceli.dev/win`.

## Build it locally

Prerequisites: Windows 10/11, Windows PowerShell 5.1, and the [NSIS compiler](https://nsis.sourceforge.io/Docs/). From `projects/marceli-win`:

```powershell
.\build.ps1 -Check
.\tests\Registry.Integration.ps1
.\release\Build-Candidate.ps1 -Phase Stage
.\release\Build-Candidate.ps1 -Phase Compile
.\tests\Installer.Integration.ps1 -InstallerPath '.\dist\MarceliWin-Setup-0.3.0-unsigned-preview.exe' -ExpectedScriptPath '.\dist\stage\MarceliWin.ps1'
.\release\Build-Candidate.ps1 -Phase Finalize -SourceCommit '<exact 40-character source SHA>'
```

The `Marceli Win installer candidate` GitHub Actions workflow runs this process and uploads ZIP + EXE + SHA-256 release manifest as downloadable workflow artifacts. Preview artifacts are **unsigned**, visibly labelled `unsigned-preview` and do not receive release publication automatically.

## Real changes are tested safely

`tests/Registry.Integration.ps1` uses only a unique temporary **HKCU scratch path**. It tests:

1. dry-run changes nothing;
2. creating a DWORD with a backup of its prior missing state;
3. detecting a value that is already at the requested setting;
4. rollback of the new DWORD to absence;
5. REG_SZ changes with preservation of the previous String value/type;
6. rejection of forged backup paths outside the known catalogue;
7. rejection of an attempted HKLM snapshot.

The test cleans up its temporary HKCU path. These checks improve confidence but don't prove compatibility of all real Windows tweak keys or registry permissions.

## Code signing: blocked until publisher identity is configured

We **do not** generate a fake trusted signature or claim the installer is signed. `Azure/artifact-signing-action@v2.0.0` is prepared for a separately initiated, **protected `main`-branch-only** workflow. It requires a verified Artifact Signing account and the following trusted GitHub configuration:

| Type | Name |
| --- | --- |
| Repository variable | `MARCELI_SIGNING_ENABLED` = `true` |
| Repository variables | `MARCELI_SIGNING_ENDPOINT`, `MARCELI_SIGNING_ACCOUNT`, `MARCELI_SIGNING_PROFILE` |
| GitHub Actions secrets | `MARCELI_AZURE_TENANT_ID`, `MARCELI_AZURE_CLIENT_ID`, `MARCELI_AZURE_CLIENT_SECRET` |

Private credentials should never be committed, pasted into PR comments, published in an artifact, or added to this chat. Configure protected environments, reviewers and minimal signer permissions before enabling them. On an authorised run, both staged PowerShell and the final installer are signed. A final signature check **fails closed** if the certificate is missing or invalid.

**Eligibility/cost:** Microsoft currently documents Artifact Signing public-trust eligibility for organisations in the UK and certain other jurisdictions, but narrower country availability for individual developers. Confirm exact eligibility and pricing before setting it up. Alternatives include a trusted commercial code-signing certificate or distributing through the Microsoft Store after meeting its requirements. Documentation: [Microsoft signing overview](https://learn.microsoft.com/en-us/windows/msix/package/signing-package-overview), [Artifact Signing integrations](https://learn.microsoft.com/en-us/azure/artifact-signing/how-to-signing-integrations).

The signed build currently pins the exact code-signing certificate thumbprint. Cloud-backed code-signing certificates may rotate: this is intentionally strict and will require revisiting the update trust policy for certificate rollover before automatic updates are enabled.

## Release integrity and update verification

- `release/New-ReleaseManifest.ps1` generates `release-manifest.json` with version, source commit, asset filenames/sizes and SHA-256 hashes **after** signing, if signing is enabled.
- `release/Test-ReleaseIntegrity.ps1` checks manifest shape, duplicate/unsafe filenames and all hashes. `-RequireSignature -ExpectedPublisherThumbprint ...` additionally checks Windows Authenticode trust and exact expected signer identity.
- `release/Check-Update.ps1` checks the repository's official **latest stable GitHub Release**, downloads its manifest/assets to a per-user staging folder, and **requires** an independently pinned trusted publisher certificate. It **does not** run the downloaded code, install it, bypass UAC or accept unsigned updates.
- The packaging CI includes negative tests ensuring both **tampering** and **missing trusted publisher identity** are rejected.
- GitHub Actions includes an optional `actions/attest@v4` provenance step on an explicit workflow dispatched from the trusted default branch. Attestation proves build origin/integrity, **not Windows publisher trust** or that the application has no bugs. [GitHub attestation documentation](https://docs.github.com/en/actions/concepts/security/artifact-attestations).

**Important:** A SHA-256 hash in a manifest served alongside an unsigned installer is not a trusted identity guarantee. Only a trusted, verified code-signing identity (or an independently trusted hash/signature) provides authenticity.

## Before calling this stable

- Obtain a real publisher signing identity and verify both .ps1 and .exe signatures.
- Manual install/uninstall and non-admin smoke on real Windows 10/11 systems; DPI, accessibility, high contrast, anti-malware and PowerShell policies.
- Independently review state-changing repair actions, app installs, winget licences and rollback.
- Resolve code-signing certificate rotation / update trust continuity.
- Protect release workflow/secrets, set branch protections and verify GitHub provenance.
- Publish stable release notes, a verified installer checksum, support contact and rollback instructions.
- Have a human approve public publication; the draft PR and CI preview don't do it automatically.

See [ENGINEERING.md](ENGINEERING.md) for the larger threat model and architecture review.
