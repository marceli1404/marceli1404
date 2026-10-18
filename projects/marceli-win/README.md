# Marceli Win — 0.2 developer preview

**Your Windows. Your choices. A fluid control centre.**

Original, independently written Windows 10/11 PowerShell + WPF utility with a morphing desktop interface, an animated landing page and guarded Windows maintenance workflows.

## Features currently implemented

| Area | Current implementation |
| --- | --- |
| Applications | 52 curated WinGet package entries; searchable cards; select-visible / clear; install selection; installed-package inventory; app upgrades |
| Tweaks | 29 user-level registry preferences with preview, confirmation, a last-batch undo and local backup history |
| Profiles | Safe, Balanced, Gaming, Developer, Privacy, Focus and Accessibility presets; all previewable |
| Windows actions | 52 named allowlisted action entries, including Windows Settings shortcuts, Task Manager, Resource Monitor, Device Manager, Disk Cleanup and diagnostics |
| Gaming | Game Mode, background capture preferences, graphics/HDR, Game Bar, mouse and audio settings, DirectX Diagnostics |
| Network | Adapter and network settings, IP information, DNS flush, ping, route table, netstat and traceroute |
| Repair | DISM CheckHealth/ScanHealth/RestoreHealth, SFC, online disk scan, Reliability Monitor, WinGet upgrades |
| Recovery | Latest tweak-batch undo, archive of earlier backup batches, restore-point request, local diagnostic report |
| Portability | Import/export of selected app + tweak IDs in a validated JSON profile; imported selections never execute automatically |
| UI | Sidebar navigation, ambient animated gradients, morphing blob geometry, animated panel changes, global search (Ctrl+K), motion-off switch |
| Web | Responsive CSS morphing visuals, interactive filter/searchable feature explorer, preview illustration, copyable commands and reduced-motion support |
| Privacy | No telemetry, remote command source, or background analytics. Activity logs stay in the local user profile |

**Catalogue counts do not imply that all actions are unique capabilities or that all Windows versions support every registry value.** Some shortcuts vary by Windows version, and individual WinGet packages may be unavailable in your region.

## Run & inspect

Read the [PowerShell source](MarceliWin.ps1) before launching it.

```powershell
irm https://win.marceli.dev/win -OutFile .\MarceliWin.ps1
notepad .\MarceliWin.ps1
powershell.exe -NoProfile -File .\MarceliWin.ps1
```

For advanced use only, the optional one-line command is:

```powershell
irm https://win.marceli.dev/win | iex
```

The website is at [win.marceli.dev](https://win.marceli.dev). For a pinned, independently verifiable version, download source from a specific GitHub commit or signed release instead of executing a moving URL.

## Safe presets and automation

The only headless non-changing mode currently intended for automation is:

```powershell
powershell.exe -NoProfile -File .\MarceliWin.ps1 -Preset Safe -WhatIf
```

To apply a preset from the CLI, the script asks you to type `APPLY` unless `-Yes` is explicitly supplied. The WPF interface always requests confirmation even if `-Yes` is specified.

## Architecture

- `MarceliWin.ps1`: single-file original WPF application and allowlisted actions.
- `site.html`: standalone responsive promotional/docs page with CSS morphing animation and client-side filtering.
- `worker.js`: Cloudflare edge router. It serves the PowerShell script at `/win`, the website at `/` and `/about`, and points to a commit-pinned GitHub source.
- `LICENSE`: original MIT licence.
- GitHub Actions runs PowerShell parsing, safe-preset dry-run and WPF-load smoke checks on Windows.

## Safety & known limits

**Preview only — not yet certified for production use.** Windows GitHub Actions verifies that the WPF interface parses and loads and that a safe preview can run. This does not substitute for interactive manual checks on real hardware.

- Tweaks use user-level registry values and record original values before changes. The most recent batch is directly undoable. Previous backup JSON files are archived, but archived batches are not selectable through the GUI yet.
- Never use arbitrary “debloat” procedures that disable Defender, Windows Update, UAC, anti-cheat or essential services. This release intentionally avoids those.
- Package managers are third-party software supply chains: review any requested app, version, sources, installer privileges and licences.
- Native repair tools and app installs can take time and may briefly block the WPF event loop. Background progress and cancellable jobs are future work.
- Windows restore-point creation needs admin privileges and an enabled System Protection configuration.
- Some Windows Settings URI shortcuts and preference keys vary by version. No registry toggle guarantees performance improvement.
- Script is **not digitally code-signed**.
- The available automated tests do **not** cover all Windows builds or every system-modifying action.
- Creating a system restore point and a Windows backup is recommended before major changes.

## Attribution

Original implementation written for Marceli Win. This project is independent of Chris Titus Tech and is **not affiliated or endorsed**. The public open-source architecture of [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) was reviewed as a reference; no WinUtil source files were copied. The [morluto/rea](https://github.com/morluto/rea) project was inspected as a potential reverse-engineering aid, but it was not executed in this build environment.

## Hosting notes

`win.marceli.dev` is managed separately by Cloudflare Workers. Hosting an endpoint at `marceli.dev/win` requires safely proxying and routing the existing apex domain without disrupting its current origin, so it is intentionally not configured yet.

## Licence

MIT — see [LICENSE](LICENSE).
