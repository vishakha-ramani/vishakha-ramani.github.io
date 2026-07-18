# Blog trilogy visual upgrade — design

Date: 2026-07-17
Status: approved by Vishakha (chat), pending spec review

## Goal

Make the three published freshness-trilogy posts visually appealing: custom figures, better structure, and a designed series experience. Style is "clean editorial" — minimal flat SVG matching site typography, adapting to al-folio's light/dark themes. Charts are schematic (labeled illustrative), not data reproductions.

The three posts:

- `_posts/2026-07-15-a-lock-can-make-data-fresher.md` (analysis paper, arXiv 2304.11683)
- `_posts/2026-07-16-the-router-that-measured-freshness.md` (testbed paper, arXiv 2304.14603)
- `_posts/2026-07-17-freshness-has-a-memory-bill.md` (age-memory paper, arXiv 2402.06860)

## Figure inventory (8)

Post 1 (3):

1. **System diagram** — app server, forwarder + FIB table, moving mobile user; writer and reader contending for the table.
2. **Mechanism panel** — side-by-side RWL vs RCU timelines: RWL reader blocks then reads fresh; RCU reader proceeds and reads stale. The title intuition in one image.
3. **Regime chart** — schematic crossing curves (app age vs location-update rate), RCU wins left, RWL wins right; small inset bars for preemption gains (~15% RCU, ~45% RWL).

Post 2 (3):

4. **Testbed diagram** — source machine with sender+receiver threads sharing one clock; forwarder with control/data rings around hash-table FIB.
5. **U-curve chart** — schematic age vs sending rate, annotated regimes (fresher-with-rate left, batching penalty past the knee ~4 Mpps).
6. **Batching explainer** — strip showing packets accumulating into a burst while age grows.

Post 3 (2):

7. **Version-pinning diagram** — writer publishes version chain; readers pin old versions through grace periods; small sawtooth age track underneath.
8. **Trade-off chart** — schematic age vs memory curve with the 1 + λ/μ ceiling as asymptote.

Chart captions say "illustrative" and point to the paper's real figure.

## Structure upgrades

- **Series nav**: reusable `_includes` component replacing the italic intro line. Top box ("Freshness in shared memory · Part N of 3" with links) plus prev/next links at the bottom of each post.
- **Thumbnails**: `thumbnail:` front matter per post (simplified lead figure) so the blog index shows images. Standalone files (index loads via `<img>`).
- **Math**: post 3's worded formulas become MathJax notation (2/α, 1 + λ/μ). MathJax is already enabled site-wide.
- **Key-result callout**: one quiet bordered callout per post with the headline result, styled in custom Sass.

## Technical approach

- Figures authored as SVG fragments in `_includes/` and included **inline** so they inherit page CSS variables; light/dark follows the site toggle with one set of sources.
- Colors: `var(--global-text-color)`, `var(--global-theme-color)`, plus 2–3 accent variables defined in custom Sass.
- Thumbnails: separate small standalone SVG/PNG per post under `assets/img/blog/`.
- Load the dataviz skill before authoring the first chart (form/palette discipline).
- No JavaScript, no new dependencies.
- `docs/` is excluded from the Jekyll build (spec must not render on the live site).

## Constraints

- Writing style rules hold for captions and any new text: no em dashes, no semicolons, no prose colons.
- Public repo: nothing unreviewed or private in committed files.
- Cross-links between posts use `/blog/2026/<slug>/`.

## Verification

Local `bundle exec jekyll build`, visual check of all three posts and the blog index in light and dark themes, then commit, push, confirm live URLs render (HTTP 200 and figures visible).
