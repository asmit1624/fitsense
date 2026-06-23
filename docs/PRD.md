# FitSense — Product Requirements Document
*Retrospective spec. Written after the MVP was built.*

---

## Problem Statement

Indian online fashion retail has a size and fit problem:

- Every brand has a size chart — but charts describe garments, not people.
- Sizing is not standardised: a Snitch M ≠ a Libas M ≠ an H&M M.
- "Relaxed fit," "slim cut," "oversized" mean different things to different brands.
- Shoppers guess. Roughly 30% of fashion returns are fit-related.
- Existing solutions (static size charts, "how to measure" guides) put the work on the buyer and still don't personalise.

**Insight:** A size chart is an input. What's missing is the judgement layer — something that knows the garment *and* the shopper, and gives a single, honest answer: *will this fit me, and should I buy it?*

---

## Target User

Indian online fashion shoppers (18–35) who:
- Buy regularly from D2C brands (Snitch, Libas, Bewakoof, Manyavar, H&M India, etc.)
- Are frustrated by returns or "fit regret"
- Already use Telegram or WhatsApp daily
- Don't want another app to install

---

## Product Vision

A personal stylist in your pocket — on a channel you already use. One assistant that knows your body, taste, and budget, and applies that knowledge every time you share a product link, across every brand.

---

## Core User Journey

### First time
1. User messages the Telegram bot.
2. Bot runs **StyleDNA onboarding** — 7 questions:
   - Top size (S/M/L/XL/XXL)
   - Bottom size (28/30/32/34/36)
   - Fit feel (snug / true-to-size / relaxed)
   - Chest range in cm (optional — unlocks higher confidence sizing)
   - Skin tone (warm light / warm medium / cool light / cool medium / deep)
   - Style preferences (casual western / ethnic / smart casual / streetwear / formals)
   - Budget band (under 500 / 500–1500 / 1500–3000 / 3000+)
3. Profile saved as **StyleDNA** in Postgres. Bot confirms.

### Returning user — product link
1. User pastes any product URL from a supported brand.
2. Bot:
   - Looks up the product in the catalog.
   - Fetches the user's StyleDNA.
   - Fetches the brand's real size chart.
   - **Computes the size recommendation in code** (cm math + fit preference + brand fit note).
   - Passes grounded facts + size decision to the local LLM for subjective judgements.
   - Parses and formats the LLM JSON response.
   - Replies with: Fit Score, size pick, colour advice, fabric note, value opinion, caveats, verdict (Buy / Maybe / Skip), one-liner.
3. Recommendation is logged to the `recommendations` table.

### Returning user — casual message
- Bot greets them by name and prompts them to paste a product link.

### Reset
- User types `reset`.
- Bot deletes their profile and starts onboarding from scratch.

---

## Feature Scope (MVP)

| Feature | Status |
|---|---|
| StyleDNA onboarding (7 questions, stateful) | ✅ Built |
| Fit scoring — size in code, LLM for judgement | ✅ Built |
| Router — one front door, three lanes | ✅ Built |
| Per-user profile persistence | ✅ Built |
| Multi-user support | ✅ Built |
| Reset flow | ✅ Built |
| Observability (recommendations log, n8n execution logs) | ✅ Built |
| Tappable onboarding buttons | 🔜 Roadmap |
| Computed (formula-based) Fit Score | 🔜 Roadmap |
| ShopPulse weekly digest | 🔜 Roadmap |
| Feedback loop (👍/👎 → profile update) | 🔜 Roadmap |
| Cloud deployment (always-on) | 🔜 Roadmap |
| Real catalog ingestion | 🔜 Roadmap |

---

## The Sizing Engine

The most important PM decision: **keep the size recommendation in deterministic code**.

Why not let the LLM decide size?
- A 3B general-purpose model can confidently give wrong sizing advice.
- Size has a right answer. It's cm math against a chart.
- LLM errors in subjective advice (colour, value) are low-stakes. A wrong size ruins the purchase.

**Logic (with chest range):**
```
target = midpoint(chest_min, chest_max) + ease
ease   = snug: +0cm  |  true: +3cm  |  relaxed: +6cm
       + brand_slim_penalty: +2cm if brand fit_note flags slim cut
recommended = first size where size_chart[size].chest_cm >= target
```

**Logic (without chest range):**
```
anchor = user's usual size
cm_for_anchor = brand_size_chart[anchor].chest_cm
fitted  = anchor
relaxed = next size up (if available)
report both options + brand fit note
```

**Confidence levels:**
- High — chest range provided, brand chart found, fit preference known
- Good — usual size known, brand chart found
- Moderate — usual size known, no brand chart (generic advice)
- Low — no size data available

---

## The LLM's Job (Only This)

After the size decision is locked, the LLM receives:

```json
{
  "fit_score": "<0-100, holistic judgement>",
  "colour_advice": "<colour vs skin tone advice>",
  "fabric_note": "<fabric vs style/weather advice>",
  "value_assessment": "<price vs budget band>",
  "caveats": ["<any watch-outs>"],
  "verdict": "Buy | Maybe | Skip",
  "one_liner": "<under 20 words>"
}
```

The prompt explicitly forbids the model from recomputing size. JSON repair runs on the output before it reaches the user.

---

## Success Metrics

| Metric | Definition | Target (MVP pilot) |
|---|---|---|
| Onboarding completion rate | Users who complete all 7 questions / users who start | >80% |
| Size acceptance | Users who agree with recommendation / users who see one | Baseline TBD |
| Buy verdict accuracy | "Buy" items that were actually purchased | Baseline TBD |
| D7 retention | Users who share a link in 7 days of onboarding | >30% |

---

## Constraints

- **₹0 infra budget** — local LLM, self-hosted n8n, free Cloudflare tunnel
- **No live scraping** — catalog is seeded mock data; ingestion is future scope
- **Single-instance** — laptop-hosted, not horizontally scalable in MVP
- **Telegram only** — WhatsApp Business API requires a verified business + cost

---

## Out of Scope (MVP)

- WhatsApp (requires verified business account)
- Payment or affiliate integration
- Computer vision / image-based product parsing
- Multi-language support
- iOS/Android native app
