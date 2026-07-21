# GGW Connect — Product Spec: Decisions & Open Questions

Living document. Captures what's been agreed, what's still undecided, and where
the current build conflicts with the agreed behaviour.

- **Last updated:** 21 Jul 2026
- **Source:** Meeting with Stan, 21 Jul 2026
- **Build status:** Frontend prototype, mock data, no backend yet.

---

## 1. Tournament Lifecycle

The end-to-end flow agreed in the 21 Jul meeting:

1. Admin **creates a tournament** (capacity ~50 players).
2. Tournament is published — golfers see it and tap in ("who wants to play").
3. Players enter via one of the routes in [§2](#2-entry-rules).
4. Admin **accepts** requests where approval is required → roster fills (e.g. 40 of 50).
5. Players inside the tournament **challenge each other** → matched → **locked in**.
6. **Tee sheet is generated** from the locked-in pairings.
7. **Invites remain open until 48 hours before** the round.
8. **At T-48h the roster locks** — no further entries or invites.
9. Tee sheet is **exported as a PDF and emailed to the golf course**.
10. **Only the admin can edit the tee sheet** thereafter.
11. If tee times change, **every affected player is notified**.
12. After the round: **scorecard returns → results entered into the tee sheet → feeds handicap**.

---

## 2. Entry Rules

Membership is the fast path; the other routes exist for non-members.

| Who | What happens on tap | Approval needed? |
|---|---|---|
| **Already a club member** | Goes straight into the tournament | ❓ See [Q1](#open-questions) |
| Non-member — **joins the club** | Becomes a member → then straight in | No |
| Non-member — **invited** | Enters via the invite | No |
| Non-member — **requests to play** (without joining the club) | Awaits admin decision | **Yes** |

**Key point:** joining the club is *not* a prerequisite for playing — requesting to
play without joining is a first-class route.

---

## 3. Tee Sheet Rules

- Generated from locked-in challenge pairings; both challengers share a tee time.
- **Admin-only editing** once published.
- **Change notifications:** any player whose tee time changes is notified.
- **Why times change:** if the tournament is under-subscribed (e.g. 10 short), the
  golf course may backfill empty slots with its own players, shifting our players' times.
- **Delivery to course:** exported as a **PDF** and sent by **email**.

---

## 4. Results & Handicap

- After the round the **scorecard comes back** from the course.
- Results are **entered into the tee sheet** (per player).
- Those results **feed the handicap calculation**.

---

## 5. Rankings & Handicap Model

| Surface | Ranked by |
|---|---|
| **Top 50** | **Challenge results** — *not* handicap |
| **Club leaderboard** | **Club handicap** — each club sets its own rules |
| **Player profile** | **Global handicap**, optional/display-only |

**Global handicap is not mandatory.** Because every club uses different rules, the
club handicap is the meaningful number. A player may *optionally* publish a global
handicap on their profile so golfers elsewhere in the world can gauge them when
they travel.

---

## 6. Decisions (Agreed)

| # | Decision |
|---|---|
| D1 | Tournaments have a capacity (~50); roster fills below it (e.g. 40). |
| D2 | Three entry routes for non-members: join club, be invited, or request to play. |
| D3 | Request-to-play **without** joining the club is explicitly allowed. |
| D4 | Approval is required for the request-to-play route. |
| D5 | Invites open until **T-48h**; roster **locks** inside 48 hours. |
| D6 | Tee sheet is **admin-editable only**. |
| D7 | Tee-time changes trigger notifications to affected players. |
| D8 | Tee sheet goes to the course as a **PDF via email**. |
| D9 | **Top 50 is challenge-based**, not handicap-based. |
| D10 | **Club leaderboard uses club handicap**, not global. |
| D11 | Global handicap is **optional**, shown on profile for travelling golfers. |
| D12 | Post-round results are entered into the tee sheet and feed handicap. |
| D13 | Under-subscribed tournaments may be backfilled by the course, shifting times. |
| D14 | *Recommendation:* build member auto-admit as a **per-tournament setting**, so Q1's answer just sets the default. |

---

## 7. Open Questions

To raise with Stan.

| # | Question | Why it matters |
|---|---|---|
| Q1 | Do **club members** also need admin approval to join a tournament, or are they auto-in? | Decides whether entry is one tap or always queued. *(Mitigated by D14.)* |
| Q2 | **Top 50 formula** — total wins, win rate, or a points system? Does a loss cost you? | Can't build the ranking without the rule. |
| Q3 | **Club handicap** — set manually by the club admin, or auto-calculated from rounds played at that club? | Determines whether we need a calculation engine or just admin entry. |
| Q4 | Who is the **tee sheet admin** — the club admin, or a separate tournament-organiser role? | Decides the permission model. |
| Q5 | **Scorecard entry** — does the admin enter results for everyone, or do players self-enter? | Very different screens. |
| Q6 | **Backfilled outside players** — do the course's own players appear on our tee sheet as placeholders? | Decides whether tee sheet rows must support non-app players. |
| Q7 | **Email** — one-tap via the device's mail composer (human presses send), or fully automated server send? | Automated sending requires a backend mail service. |
| Q8 | Can a player **withdraw** before the lock? What happens to their challenge pairing after lock? | Affects pairing integrity and tee sheet gaps. |
| Q9 | Is **capacity fixed at 50**, or set per tournament? | Trivial either way, but affects the create form. |
| Q10 | Does the **48h lock also freeze challenges/pairings**, or only new entries? | Affects when the tee sheet can be finalised. |
| Q11 | Meeting note **point 7 was blank** — was anything missed? | — |

---

## 8. Conflicts With the Current Build

These already exist in the app and now need rework.

| # | Currently | Needs to become |
|---|---|---|
| C1 | Top 50 ranks players by **handicap** | Ranked by **challenge results** (Q2) |
| C2 | Club leaderboard ranks by the single global handicap | Ranked by **per-club handicap** |
| C3 | Each player has **one** handicap used everywhere | **Per-club handicaps** + one optional global |
| C4 | Challenge flow **forces** "join club → join tournament" | Allow request-to-play route; gate challenges on *"both in the same tournament"* only |
| C5 | Tee sheet is a **read-only** list from challenges | Real tee times, admin editing, roster, change notifications |
| C6 | No tournament **creation**, capacity, or date-driven logic | Create form + capacity + T-48h lock |
| C7 | Request-to-play approval is **randomly mocked** | Real admin approval queue |
| C8 | Results tab is display-only | Scorecard/results entry feeding handicap |

---

## 9. Implementation Notes

- **PDF export** needs the `pdf` + `printing` / `share_plus` packages. These existed in
  the old GetX app but were dropped in the clean-architecture rebuild — easy to re-add.
- **Email without a backend** means the device's mail composer opens with the PDF
  attached and the user presses send. A fully automated send needs a backend service (Q7).
- **T-48h lock** needs a real tournament date/time; the current tournament model already
  carries date + tee time, so this is mostly logic.
- **Admin roles**: club members already carry an `isAdmin` flag, but it isn't wired to any
  permissions yet.
- **Tier gating** (Free / Paid / Superuser) exists with upgrade prompts, but nothing is
  actually locked — `PermissionService` currently returns `true` for everything.
- Everything remains **mock data**; each repository is behind an interface so it can be
  swapped for a live API without UI changes.
