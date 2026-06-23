# FitSense — Build Journey
*How this actually got built. The decisions, the dead ends, the fixes.*

---

## Why this project exists

The case study came first. I was analyzing the Indian D2C fashion market — specifically the gap between "size chart exists" and "shopper actually knows if something will fit." The insight was simple: sizing tools are garment-centric. A personal stylist is shopper-centric.

The product spec wrote itself. The question was whether I could actually build it — end-to-end, with no backend engineering background, on a free stack.

---

## Phase 0 — Choosing the stack

**The original plan was WhatsApp.** WhatsApp is where Indian shoppers actually live. But WhatsApp Business API requires a verified business, a BSP (Business Solution Provider), and costs money per message. That killed it for a solo MVP.

**Switched to Telegram.** Free bot API, instant setup via @BotFather, near-identical UX for this use case. The architecture stays the same — swapping back to WhatsApp in production is a channel config change, not a rebuild.

**For the AI:** the plan was Claude API (best at following structured prompts). For cost-zero local development, landed on **Ollama running qwen2.5:3b** — a 3B model from Alibaba, small enough to run on a laptop CPU.

**For the workflow engine:** n8n over custom code. Every bot step (receive message → query DB → call AI → send reply) is a node you can see, debug, and rerun. For a solo builder, observability and speed of iteration beat clean code architecture.

---

## Phase 1 — Onboarding (StyleDNA)

### The stateless problem

A Telegram bot has no memory. Every incoming message arrives fresh. "Is this person on question 3?" needs to live somewhere persistent.

**Solution: `onboarding_sessions` table.** Each row is `{telegram_id, current_question, answers_so_far}`. When a message arrives:
1. Look up the user's session row.
2. Validate their answer to the current question.
3. Save the answer, increment the question counter.
4. Send the next question.

When question 7 is done, write all answers into the `users` table and delete the session row. The user is onboarded.

### What the 7 questions are and why

| # | Question | Why |
|---|---|---|
| 1 | Top size | Anchor for size math |
| 2 | Bottom size | Anchor for size math |
| 3 | Fit feel | Determines cm ease added to target |
| 4 | Chest range (optional) | Unlocks high-confidence exact sizing |
| 5 | Skin tone | Drives colour advice |
| 6 | Style preferences | Drives fabric and outfit advice |
| 7 | Budget band | Drives value framing + future ShopPulse |

Question 4 is the key unlock — with a real chest measurement, size math becomes exact. Without it, we anchor on usual size and give fitted-vs-relaxed options. Both are honest.

---

## Phase 2 — Fit Scoring

### The most important architecture decision

Early versions let the LLM handle everything — size, colour, value, verdict. This was wrong.

**A general-purpose 3B model can confidently give wrong sizing advice.** It reasons from training data, not from brand-specific cm charts. Asking it "what size should I buy at Snitch?" is asking it to guess.

The fix: **size computation moves entirely to code.** The LLM only sees:
- The already-decided size recommendation (injected into the prompt)
- An explicit instruction: *"Size has ALREADY been decided. Do NOT recompute size."*

Code handles what has a right answer. The LLM handles opinions.

### The prompt architecture

Every fit-score call builds a prompt with:
1. A system persona ("You are FitSense, an honest personal stylist...")
2. The user's StyleDNA (skin tone, style, budget band, usual size)
3. The product facts (name, brand, price, fabric, colours, description)
4. The **already-computed size decision** (not the raw chart — the answer)
5. Strict JSON output format with fixed keys

The LLM's job is narrow: fill 7 JSON fields. The smaller the job, the less it can go wrong.

### JSON repair

Small local models sometimes return malformed JSON — trailing commas, missing quotes, prose before the object. A repair step runs before parsing: strip markdown fences, find the first `{` and last `}`, attempt parse. If it still fails, fall back to a safe "Maybe" verdict with a note.

---

## Phase 3 — The Router

### The "one front door" problem

At Phase 2, onboarding and scoring were separate n8n workflows. A Telegram bot has one webhook URL — one entry point. Only one workflow can be Published at a time.

The router fixes this. It's a single workflow that:
1. Receives every Telegram message.
2. Queries Postgres: "Do I know this person? Are they mid-onboarding?"
3. Branches:
   - New user / `reset` command → onboarding lane
   - Mid-onboarding → continue onboarding (next question)
   - Onboarded + product link → scoring lane
   - Onboarded + anything else → welcome-back message
4. Calls the appropriate downstream logic.

The router doesn't *do* anything — it *directs* traffic. The scoring and onboarding logic stayed the same.

---

## Bugs fixed in real usage

### 1. Dead tunnel (silent bot)
**Symptom:** Bot stopped replying overnight.
**Root cause:** The free Cloudflare tunnel generates a new URL on every restart. Telegram's webhook was still pointing at the old URL. All messages went nowhere.
**Fix:** Restart tunnel → copy new URL → update `WEBHOOK_URL` in docker-compose → `docker compose up -d` → republish workflow.
**Lesson:** This is why the daily startup routine exists. Permanent fix = cloud VPS with fixed domain (roadmap item 7).

### 2. Empty database (OneDrive corruption)
**Symptom:** No products, no size guides. Fit scoring returned "product not found."
**Root cause:** OneDrive had silently converted `01_schema.sql` and `02_seed.sql` into empty *folders* (a known OneDrive sync quirk with extensionless files).
**Fix:** Replaced with real files, loaded manually via `psql`.
**Lesson:** Don't rely on OneDrive sync for plain text source files. Use git.

### 3. Reset-flow routing bug
**Symptom:** A user who typed `reset` and went through onboarding again was sent the "Welcome back!" greeting on Question 2 instead of the next question.
**Root cause:** The router checked only the permanent `onboarding_done` flag on the `users` table, not whether an active onboarding session existed. After reset, `onboarding_done` was TRUE (carried over), so the router assumed a returning user.
**Fix:** Router now checks for an active row in `onboarding_sessions` first. If one exists, route to onboarding regardless of `onboarding_done`.
**How it was caught:** n8n execution logs showed the exact node where the branch went wrong. Root-caused and shipped within the hour.

---

## What I'd do differently

1. **Use git from day one.** File management via OneDrive caused actual data loss. A git repo would have prevented the schema corruption.

2. **Build the router before the individual workflows.** Building onboarding and scoring as separate workflows first made sense for iteration speed, but the integration step (the router) was non-trivial. Starting with the routing architecture would have made the individual flows cleaner.

3. **Define success metrics before building.** I named "size acceptance rate" as the key metric after the fact. Building the `recommendations` log from day one was the right call — but the eval set (ground truth for accuracy) is still a roadmap item.

4. **The fit score should have been a formula from the start.** LLM-guessed 0–100 scores cluster at round numbers and can't be explained. A weighted formula (size match + colour + style + budget) would have been more defensible and consistent. It's fixable — and it's roadmap item 1.

---

## What this proves

A working AI product with real personalisation can be built on a ₹0 stack in weeks by a solo PM who can pair with AI coding tools. The constraint forces better architectural decisions: if you can't hand-wave away reliability with a bigger model, you have to think harder about where the model is actually needed.

**Code for what has a right answer. AI for opinions.** That's the takeaway.
