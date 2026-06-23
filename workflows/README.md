# Workflows

These are the n8n workflow JSON exports. Import them via **n8n UI → Import from file**.

## Files

| File | Description | Status |
|---|---|---|
| `FitSense_MainBot_Router.json` | The live bot — 19 nodes, 3 lanes (onboarding / scoring / greeting) | **Active** |
| `FitSense_Onboarding_Phase1.json` | Standalone onboarding workflow (superseded by Router) | Reference only |
| `FitSense_FitScoring_Phase2.json` | Standalone scoring workflow (superseded by Router) | Reference only |

## Import order

1. Import `FitSense_MainBot_Router.json`
2. Connect your Postgres credential in every node that queries the DB
3. Verify the Telegram Bot node has your bot token
4. Verify the HTTP Request node for Ollama points to `http://host.docker.internal:11434`
5. **Publish only the Router workflow** — the standalone Phase 1 and Phase 2 workflows are for reference

## How the Router works

```
Telegram Webhook
      │
      ▼
Get Context (Postgres query)
  → Is user in users table?
  → Is there an active onboarding_sessions row?
      │
      ▼
Router Brain (Switch node)
  ├── new user OR "reset" command    → Onboarding lane
  ├── mid-onboarding session active  → Continue onboarding (next question)
  ├── onboarded + URL detected       → Fit Scoring lane
  └── onboarded + anything else      → Welcome Back message
```

> **Note:** The workflow JSON files are not included in this public repo because they contain environment-specific node IDs and credentials. Export them from your own n8n instance after setup. The architecture above describes exactly what each workflow does.
