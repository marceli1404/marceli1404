// Marceli Win 0.2 distribution worker. MIT. No telemetry or arbitrary remote execution.
// Both resources are pinned to the same reviewed immutable source revision.
const SOURCE_COMMIT = "9420a1a4f72d8f5fd451638cec2e4e0253491238";
const ORIGIN = "https://raw.githubusercontent.com/marceli1404/marceli1404/" + SOURCE_COMMIT + "/projects/marceli-win/";
const PAGE = ORIGIN + "site.html";
const SCRIPT = ORIGIN + "MarceliWin.ps1";
const baseHeaders = {
  "x-content-type-options": "nosniff",
  "referrer-policy": "no-referrer",
  "x-frame-options": "DENY",
  "cache-control": "public, max-age=300, no-transform",
  "x-marceli-win-version": "0.2.1-hotfix"
};
export default {
  async fetch(request) {
    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method not allowed", {status:405,headers:{"allow":"GET, HEAD"}});
    }
    const path = new URL(request.url).pathname;
    const isPowerShell = /WindowsPowerShell|PowerShell\/\d|powershell/i.test(request.headers.get("user-agent") || "");
    // Preserve compatibility with the original root-level irm | iex example.
    const isScript = path === "/win" || path === "/MarceliWin.ps1" || (path === "/" && isPowerShell);
    const isPage = path === "/" || path === "/about" || path === "/docs" || path === "/features";
    if (!isScript && !isPage) return new Response("Not found", {status:404});
    const target = isScript ? SCRIPT : PAGE;
    let upstream;
    try { upstream = await fetch(target, {cf:{cacheTtl:300,cacheEverything:true}}); }
    catch { return new Response("Source temporarily unavailable", {status:503}); }
    if (!upstream.ok) return new Response("Pinned release source unavailable", {status:502});
    const h = new Headers(baseHeaders);
    h.set("content-type", isScript ? "text/plain; charset=utf-8" : "text/html; charset=utf-8");
    if(isScript) {
      h.set("cache-control","no-store, no-transform");
      h.set("content-disposition",'inline; filename="MarceliWin.ps1"');
      h.set("content-security-policy","default-src 'none'; frame-ancestors 'none'");
    } else {
      h.set("content-security-policy","default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src 'none'; connect-src 'none'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'none'");
    }
    // Stream source bytes unchanged: PowerShell 5.1 needs the UTF-8 BOM.
    return new Response(request.method === "HEAD" ? null : upstream.body, {status:200,headers:h});
  }
};
