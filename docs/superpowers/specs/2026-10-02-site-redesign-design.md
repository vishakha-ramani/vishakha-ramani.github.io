# Site redesign: refined al-folio (direction A)

Date: 2026-10-02. Status: awaiting review.

## Goal

The homepage currently reads as a research statement (about 1,760 words, six
`####` subsections). A visitor should learn who Vishakha is, what she works on,
and where to go next in about 30 seconds. The site should feel calm, typographic,
and editorial while staying on al-folio so upstream updates and Scholar citation
syncing keep working.

## Success criteria

- Homepage body text is 250 words or fewer, excluding the news list and paper list.
- No research detail is lost: everything cut from the homepage lives on `/research/`.
- One accent color, two typefaces, correct light and dark modes.
- Readable at 375px phone width with no horizontal scroll.
- `bundle exec jekyll build` succeeds; no broken internal links (`/research/`,
  `/publications/`, `/now/`, CV PDF).
- No content about prefill-decode disaggregation anywhere (already removed in
  commit `1f20559`; must not be reintroduced).

## Visual system

All styling lives in one new partial, `_sass/_refined.scss`, loaded last in
`assets/css/main.scss` so it overrides theme defaults without editing al-folio's
own partials. The only edits outside that file are token values.

- **Typefaces.** Body: Source Serif 4 (400, 400 italic, 600). Headings, navbar,
  buttons, metadata: Inter (400, 500, 600). Loaded via the existing
  `third_party_libraries.google_fonts` URL in `_config.yml`, replacing Roboto /
  Roboto Slab. Material Icons stays in the URL if any layout uses it.
- **Type scale.** Body 1.0625rem / line-height 1.7. h1 2rem, h2 1.375rem,
  h3 1.125rem, all Inter 600, letter-spacing -0.01em. `####` headings are no
  longer used in page content.
- **Color tokens** (set in `_themes.scss` `:root` and `html[data-theme="dark"]`):
  - Light: background `#fbfaf7`, text `#1f2328`, muted text `#5b6470`,
    accent `#0f6e6e`, divider `rgba(0,0,0,0.08)`.
  - Dark: background `#15181c`, text `#e6e6e3`, muted text `#9aa3ad`,
    accent `#5fb3b3`, divider `rgba(255,255,255,0.10)`.
  - `--global-theme-color` and `--global-hover-color` both map to the accent;
    the purple default goes away.
- **Layout.** `max_width` in `_config.yml` from 930px to 760px. Generous vertical
  rhythm: 3rem between homepage sections. Section headers are small uppercase
  Inter labels (0.8rem, letter-spacing 0.08em, muted color) with a hairline
  divider, rather than large bold headings.
- **Links.** Accent color, no underline by default, 1px underline on hover.
- **Profile photo.** Stays right-aligned on desktop, smaller (about 180px), with
  a 4px radius; stacks above the text on mobile (al-folio default behavior).
- **Footer.** Keep al-folio's footer but switch to background color with muted
  text instead of the dark grey band.

## Information architecture

Navbar order: about · research · publications · talks · blog · now · CV.
CV is the existing `/cv/` page, turned back on in the nav (`nav: true`,
nav_order 7). al-folio's header has no redirect support, so linking straight to
the PDF would need a template change; the `/cv/` page already offers the PDF.

### Home (`_pages/about.md`)

1. **Intro** (2–3 sentences): Research Staff Member at IBM T. J. Watson; performance
   modeling of computing systems; current focus on scheduling and autoscaling of
   LLM inference serving.
2. **Research themes** (three items, one line each plus one link):
   - LLM inference performance modeling → arXiv:2609.20957 and the "three numbers" post.
   - Autoscaling in llm-d (co-architect of WVA) → WVA repo.
   - Age of Information in computing systems (PhD, Rutgers 2024, advised by Roy Yates) → thesis PDF.
     A "More on my research →" link to `/research/`.
3. **News**: a hand-written Markdown list in `about.md` (most recent first, at
   most 4 items). al-folio's built-in announcements block was not used because
   its heading links to `/news/`, which this site does not have, and fixing that
   would mean editing the layout.
4. **Selected papers**: `selected_papers: true`. Selected set is the four
   entries already flagged: the arXiv preprint, WVA (CLOUD 2026), Bottlenecks of
   AI Inference (Real-Time Systems), and Lock-Based or Lock-Less (INFOCOM 2023).
5. **Social icons** (existing).
6. One sentence on cycling and piano linking to `/now/`.

### Research (`_pages/research.md`, new, nav_order 2)

Holds the current long-form homepage text, tightened by about 40%:

- **At IBM**: modeling an inference server; ADRS / simulation and agentic search
  (Nous, BLIS). Each subsection ends with links to its paper or repo.
- **PhD**: the three thesis threads (memory access, synchronization primitives,
  multi-step processing), each with paper links.
  Uses `###` subheadings. No `####`. Factual claims are preserved, not rewritten;
  tightening means removing repetition and background a reader can get from the
  linked papers.

### Publications (`_pages/publications.md`)

- Keep `{% bibliography %}` grouped by year (al-folio default).
- The arXiv entry shows a small "preprint" badge, driven by its venue text
  ("arXiv preprint") via al-folio's existing `abbr` bib field (`abbr={Preprint}`),
  so no template change is needed.
- Abstract, arXiv, PDF, code buttons restyled as Inter text pills in accent color.
- Remove the bib search box unless the list grows past about 20 entries (it has 12).

### Talks, Blog, Now

Restyled by the shared stylesheet only. Content unchanged; `/now` content is left
to the user. Nav order: research 2, publications 3, talks 4, blog 5, now 6, CV 7.

## Out of scope

- Rewriting blog posts or the `/now` race notes.
- Changing al-folio layouts or includes beyond config toggles.
- New features (search, newsletter, analytics).

## Files touched

- `_sass/_refined.scss` (new), `assets/css/main.scss` (one `@use` line)
- `_sass/_themes.scss` (token values only)
- `_config.yml` (`max_width`, Google Fonts URL, announcements settings)
- `_pages/about.md` (rewrite), `_pages/research.md` (new),
  `_pages/publications.md`, `_pages/cv.md` (nav flag), nav_order on talks/blog/now
- `_news/*.md` (new entries), `_bibliography/papers.bib` (`abbr` on the preprint only)

## Verification

- `bundle exec jekyll build` passes.
- Serve locally and check home, research, publications, a blog post, and `/now`
  in light and dark mode at desktop and 375px widths (screenshots).
- `grep -ri disaggregat _site` returns nothing.
- Word count of homepage body at or under 250.
