// Marceli Win distribution Worker (c) 2026 Marceli Pawlinski. MIT.
// Source pinned to immutable GitHub commit; no dynamic branch or third-party scripts.
const SCRIPT_URL = "https://raw.githubusercontent.com/marceli1404/marceli1404/9c813df8fea57baafe33b224288ceec963169e02/projects/marceli-win/MarceliWin.ps1";
const headers = {
  "content-type": "text/plain; charset=utf-8",
  "x-content-type-options": "nosniff",
  "cache-control": "public, max-age=300",
  "x-marceli-win-version": "0.1.0-preview"
};
const page = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Marceli Win | Windows Toolkit</title><style>
:root{color-scheme:dark}body{margin:0;background:#080d19;color:#e9edf7;font:16px system-ui,-apple-system,Segoe UI,sans-serif;line-height:1.55}
main{max-width:850px;margin:auto;padding:8vw 24px}h1{font-size:clamp(42px,8vw,82px);letter-spacing:-.05em;line-height:1.1;margin:20px 0}
h1 span{color:#a5b4fc}.eyebrow{color:#a5b4fc;font-weight:700;letter-spacing:.2em}.lead{color:#a3aec3;font-size:20px;max-width:680px}
pre{background:#131e35;border:1px solid #2c3e60;border-radius:14px;padding:20px;overflow:auto;font-size:15px}
section{margin-top:44px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:14px}.feature{background:#131e35;border:1px solid #263654;padding:20px;border-radius:12px}
a{color:#a5b4fc}small{color:#94a3b8}.warning{border-left:3px solid #a5b4fc;padding:12px 20px;background:#131e35}
</style></head><body><main><div class="eyebrow">◈ MARCELI.DEV / WINDOWS</div><h1>Meet <span>Marceli Win.</span></h1><p class="lead">An open-source Windows utility for apps, sensible tweaks, diagnostics, and presets. You control every change.</p>
<p class="warning"><strong>Preview v0.1:</strong> Download and inspect the script before running. Windows CI has checked parsing and safe preset preview; full manual UI testing remains outstanding.</p>
<section><h2>Launch after inspection</h2><pre>irm https://win.marceli.dev -OutFile .\MarceliWin.ps1
notepad .\MarceliWin.ps1
.\MarceliWin.ps1</pre><small>Requires Windows PowerShell 5.1. Some repair actions require Administrator. Never run a remote script blindly.</small></section>
<section><h2>What is included</h2><div class="grid"><div class="feature">📦 <strong>App installs</strong><p>Curated WinGet packages, no bundled installers.</p></div><div class="feature">🎛️ <strong>Reversible tweaks</strong><p>Explorer, theme, privacy and gaming settings with last-batch undo.</p></div><div class="feature">🧰 <strong>Windows repair</strong><p>DISM, SFC, disk scan, updates and DNS diagnostics.</p></div><div class="feature">🪄 <strong>Profiles</strong><p>Safe, Balanced, Gaming and Developer presets.</p></div></div></section>
<section><p><a href="/win">Download the PowerShell script</a> · <a href="https://github.com/marceli1404/marceli1404/pull/1">Source and review</a></p><small>Independent project. Not affiliated with Chris Titus Tech. No telemetry.</small></section></main></body></html>`;
export default {
  async fetch(request) {
    if (request.method !== "GET" && request.method !== "HEAD") return new Response("Method Not Allowed",{status:405,headers:{"allow":"GET, HEAD"}});
    const path = new URL(request.url).pathname;
    if (path === "/about" || path === "/win/about" || path === "/docs") return new Response(request.method==="HEAD"?null:page,{headers:{"content-type":"text/html; charset=utf-8","x-content-type-options":"nosniff","content-security-policy":"default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'"}});
    if (path !== "/" && path !== "/win" && path !== "/MarceliWin.ps1") return new Response("Not found",{status:404});
    let upstream;
    try { upstream = await fetch(SCRIPT_URL,{cf:{cacheTtl:300,cacheEverything:true}}); }
    catch { return new Response("Temporarily unavailable",{status:503}); }
    if(!upstream.ok) return new Response("Upstream source unavailable",{status:502});
    const data = request.method==="HEAD"?null:await upstream.text();
    return new Response(data,{headers});
  }
};
