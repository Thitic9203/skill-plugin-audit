#!/usr/bin/env bash
# deploy-report.sh — Publish a daily audit HTML to GitHub Pages
#
# Usage:
#   ./scripts/deploy-report.sh /path/to/daily-skill-plugin-audit-2026-04-15.html
#
# What it does:
#   1. Copies the HTML into docs/reports/YYYY-MM-DD.html
#   2. Overwrites docs/latest.html (so a permanent "latest" link always works)
#   3. Regenerates docs/index.html with the new report linked at the top
#   4. git add + commit + push to main
#   5. Prints the two public URLs to paste into Slack

set -euo pipefail

# ── Resolve repo root (script lives in scripts/) ─────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCS="$REPO_ROOT/docs"
REPORTS="$DOCS/reports"

# ── Input ────────────────────────────────────────────────────────────────────
SRC="${1:-}"
if [[ -z "$SRC" || ! -f "$SRC" ]]; then
  echo "❌ Usage: $0 /path/to/report.html"
  exit 1
fi

# Extract date from filename (YYYY-MM-DD) or fall back to today
FNAME="$(basename "$SRC")"
if [[ "$FNAME" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
  DATE="${BASH_REMATCH[1]}"
else
  DATE="$(date +%F)"
fi

DEST="$REPORTS/$DATE.html"
mkdir -p "$REPORTS"

# ── 1. Copy report + update latest.html ──────────────────────────────────────
cp "$SRC" "$DEST"
cp "$SRC" "$DOCS/latest.html"
echo "✓ Copied → docs/reports/$DATE.html"
echo "✓ Updated → docs/latest.html"

# ── 2. Regenerate index.html ─────────────────────────────────────────────────
# Collect all reports, sorted newest first
cd "$REPORTS"
mapfile -t FILES < <(ls -1 *.html 2>/dev/null | sort -r)
cd "$REPO_ROOT"

LIST_HTML=""
for f in "${FILES[@]}"; do
  d="${f%.html}"
  # Format date as "DD Month YYYY"
  pretty="$(date -j -f "%Y-%m-%d" "$d" "+%-d %B %Y" 2>/dev/null || echo "$d")"
  LIST_HTML+="        <li><a href=\"./reports/$f\"><span class=\"date\">📅 $pretty</span><span class=\"arrow\">›</span></a></li>"$'\n'
done

LATEST_DATE_PRETTY="$(date -j -f "%Y-%m-%d" "$DATE" "+%-d %B %Y" 2>/dev/null || echo "$DATE")"

cat > "$DOCS/index.html" <<HTML
<!DOCTYPE html>
<html lang="th">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Daily Skill / Plugin / MCP Audit Reports</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
  :root{--bg-primary:#1c1c1e;--bg-secondary:#2c2c2e;--bg-tertiary:#3a3a3c;--bg-elevated:#242426;--separator:rgba(255,255,255,0.09);--lbl-primary:#fff;--lbl-secondary:rgba(235,235,245,0.6);--lbl-tertiary:rgba(235,235,245,0.28);--blue:#0a84ff;--green:#30d158;--tl-r:#ff5f57;--tl-y:#febc2e;--tl-g:#28c840;}
  *{margin:0;padding:0;box-sizing:border-box}
  body{font-family:-apple-system,'Inter',BlinkMacSystemFont,sans-serif;background:var(--bg-primary);color:var(--lbl-primary);min-height:100vh;padding:24px;font-size:14px;line-height:1.6;-webkit-font-smoothing:antialiased}
  .window{background:var(--bg-secondary);border-radius:18px;box-shadow:0 8px 40px rgba(0,0,0,.7),inset 0 1px 0 rgba(255,255,255,.07);overflow:hidden;max-width:900px;margin:0 auto}
  .titlebar{background:var(--bg-elevated);padding:14px 20px 12px;display:flex;align-items:center;gap:14px;border-bottom:1px solid var(--separator)}
  .tlights{display:flex;gap:7px}
  .tl{width:12px;height:12px;border-radius:50%;box-shadow:0 0 0 .5px rgba(0,0,0,.25)}
  .tl-r{background:var(--tl-r)}.tl-y{background:var(--tl-y)}.tl-g{background:var(--tl-g)}
  .ttl{flex:1;text-align:center;font-size:13px;font-weight:500;color:var(--lbl-secondary)}
  .content{padding:32px}
  h1{font-size:24px;font-weight:700;letter-spacing:-0.3px;margin-bottom:6px}
  .sub{color:var(--lbl-secondary);font-size:13px;margin-bottom:28px}
  .latest-banner{background:linear-gradient(135deg,rgba(10,132,255,0.15),rgba(48,209,88,0.12));border:1px solid rgba(10,132,255,0.3);border-radius:12px;padding:16px 20px;margin-bottom:24px;display:flex;align-items:center;justify-content:space-between;gap:16px}
  .latest-banner .label{font-size:11px;font-weight:600;color:var(--blue);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px}
  .latest-banner .title{font-size:15px;font-weight:600}
  .latest-banner a.btn{background:var(--blue);color:#fff;text-decoration:none;padding:10px 18px;border-radius:8px;font-size:13px;font-weight:600;white-space:nowrap;transition:opacity 0.2s}
  .latest-banner a.btn:hover{opacity:0.85}
  h2{font-size:15px;font-weight:600;color:var(--lbl-secondary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:12px}
  .reports{list-style:none}
  .reports li{background:var(--bg-tertiary);border:1px solid var(--separator);border-radius:10px;margin-bottom:8px;transition:background 0.15s}
  .reports li:hover{background:#454548}
  .reports a{display:flex;align-items:center;justify-content:space-between;padding:14px 18px;color:var(--lbl-primary);text-decoration:none;font-size:14px}
  .reports .date{font-weight:500}
  .reports .arrow{color:var(--lbl-tertiary);font-size:18px}
  .footer{margin-top:28px;padding-top:20px;border-top:1px solid var(--separator);font-size:11px;color:var(--lbl-tertiary);text-align:center}
  .footer a{color:var(--blue);text-decoration:none}
</style>
</head>
<body>
  <div class="window">
    <div class="titlebar">
      <div class="tlights"><span class="tl tl-r"></span><span class="tl tl-y"></span><span class="tl tl-g"></span></div>
      <div class="ttl">Daily Skill / Plugin / MCP Audit — Reports Index</div>
      <div style="width:52px"></div>
    </div>
    <div class="content">
      <h1>📊 Daily Audit Reports</h1>
      <p class="sub">Automated daily verification of top 25 Claude Skills, Plugins &amp; MCPs — updated every Thai workday at 10:30 AM.</p>
      <div class="latest-banner">
        <div>
          <div class="label">Latest Report</div>
          <div class="title">$LATEST_DATE_PRETTY — 25 Tools Verified &amp; Installed</div>
        </div>
        <a class="btn" href="./latest.html">Open →</a>
      </div>
      <h2>All Reports</h2>
      <ul class="reports">
$LIST_HTML      </ul>
      <div class="footer">
        Auto-deployed from <a href="https://github.com/Thitic9203/skill-plugin-audit">Thitic9203/skill-plugin-audit</a> · macOS Dark Theme
      </div>
    </div>
  </div>
</body>
</html>
HTML

echo "✓ Regenerated → docs/index.html"

# ── 3. Git commit + push ─────────────────────────────────────────────────────
cd "$REPO_ROOT"
git add docs/
if git diff --cached --quiet; then
  echo "ℹ️  No changes to commit."
else
  git commit -m "Daily audit report: $DATE" >/dev/null
  git push origin main
  echo "✓ Pushed to GitHub"
fi

# ── 4. Print URLs ────────────────────────────────────────────────────────────
BASE="https://thitic9203.github.io/skill-plugin-audit"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📋 Share these URLs in Slack"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Today:  $BASE/reports/$DATE.html"
echo "  Latest: $BASE/latest.html"
echo "  Index:  $BASE/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ⏱️  GitHub Pages usually takes 30–60s to refresh after push."
