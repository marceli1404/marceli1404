# Marceli Win (preview v0.1)

A lightweight, independently written Windows 10/11 PowerShell + WPF utility by Marceli Pawliński. **Experimental: review and test on a noncritical Windows machine before relying on it.**

## Features
- Dark, branded 6-tab WPF interface
- System overview (Windows build, CPU, memory, elevation)
- Curated WinGet installs (browsers, development, utilities, media and gaming)
- Reversible per-user Windows Explorer, theme, privacy and gaming preferences
- Preview-first Safe, Balanced, Gaming and Developer profiles
- DISM scan/repair, SFC, disk scan, DNS flush, Windows Update settings and app upgrades, with confirmation
- Local timestamped logs; last-batch registry backup and rollback
- Non-interactive profile preview with `-Preset Safe -WhatIf`

## Running locally
Download and **read** `MarceliWin.ps1`, then launch in **Windows PowerShell 5.1**:

```powershell
powershell.exe -NoProfile -File .\MarceliWin.ps1
```

When the endpoint is confirmed live, the optional one-line convenience command is:

```powershell
irm https://win.marceli.dev | iex
```

Do not use the convenience command until the endpoint and script are checked. Prefer downloading, inspecting and running a pinned version.

## Safety model
No analytics, injected advertisements, third-party downloaded PowerShell, antivirus disabling, destructive service changes or Windows Update disabling. WinGet itself obtains packages from your configured sources. Diagnostics and installations launch official tools. Registry tweaks are opt-in, individual and backed up **before** the batch; the backup stores only the **latest** batch. Some Windows builds ignore certain registry settings. Changes may require signing out. Admin elevation is only required for relevant diagnostic operations; the tool does not bypass UAC.

### Important limitations
- **Not tested on a physical Windows 10/11 machine yet**; Windows CI verifies parsing and dry-run only.
- WinGet installers and DISM/SFC run synchronously and can temporarily make the UI unresponsive.
- Last-batch undo is not a full system restore; create a Windows restore point before substantial changes.
- The current script is not code-signed.
- Avoid changing settings used by accessibility features or game capture if needed.

## Source and attribution
This is an original implementation informed by the public architecture of [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) (MIT); no source files from that project are copied. It is **not affiliated with or endorsed by Chris Titus Tech**. [morluto/rea](https://github.com/morluto/rea) was researched as an analysis aid; it could not be installed in the current build environment, and no reverse-engineering tool run is claimed.

## Hosting
`worker.js` serves this script from a commit-pinned public GitHub URL via Cloudflare Workers. Use a dedicated custom domain such as `win.marceli.dev` until the apex DNS can be safely proxied. A route on `marceli.dev/win` only works after that zone's apex DNS is orange-clouded without breaking the existing upstream site.

## Licence
MIT — see `LICENSE`.