# skill-plugin-audit

Daily audit reports for top 25 Claude Skills / Plugins / MCP Servers, hosted on GitHub Pages.

## 🌐 Live URLs

- **Latest report** (always points to newest): https://thitic9203.github.io/skill-plugin-audit/latest.html
- **Reports index**: https://thitic9203.github.io/skill-plugin-audit/
- **Specific date**: https://thitic9203.github.io/skill-plugin-audit/reports/YYYY-MM-DD.html

## 📁 Structure

```
skill-plugin-audit/
├── docs/                    # GitHub Pages serves from here
│   ├── index.html           # Auto-generated landing page
│   ├── latest.html          # Always the newest report (for Slack pinning)
│   └── reports/
│       └── YYYY-MM-DD.html  # Daily archive
├── scripts/
│   └── deploy-report.sh     # One-command deploy
└── README.md
```

## 🚀 Daily deploy (single command)

```bash
./scripts/deploy-report.sh /path/to/daily-skill-plugin-audit-YYYY-MM-DD.html
```

The script will:

1. Copy the HTML into `docs/reports/YYYY-MM-DD.html`
2. Overwrite `docs/latest.html`
3. Regenerate `docs/index.html` with the new entry
4. `git add` + `commit` + `push`
5. Print Slack-ready URLs

## ⚙️ First-time GitHub Pages setup (do once)

1. Push this repo to `https://github.com/Thitic9203/skill-plugin-audit`
2. Go to **Settings → Pages**
3. Source: **Deploy from a branch**
4. Branch: `main` · Folder: `/docs`
5. Save — wait ~30 seconds, site is live.

## 💬 Slack link format

Pin this single link in the channel — it always opens the newest report:

```
<https://thitic9203.github.io/skill-plugin-audit/latest.html|📊 View Latest Audit Report>
```
