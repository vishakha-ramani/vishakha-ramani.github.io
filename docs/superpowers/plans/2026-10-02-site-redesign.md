# Site Redesign (Refined al-folio) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the text-heavy homepage into a short, elegant landing page, move long-form research text to a new `/research/` page, and apply a calm serif/sans visual system on top of al-folio.

**Architecture:** All visual changes live in one new Sass partial (`_sass/_refined.scss`) loaded last, plus token values in `_themes.scss` and three `_config.yml` settings. Content changes are Markdown edits to `_pages/`. No al-folio layouts or includes are modified. A shell script, `bin/check-redesign.sh`, checks the built `_site/` against the spec and is the test for every task.

**Tech Stack:** Jekyll (al-folio theme), Sass, Liquid, jekyll-scholar, Google Fonts, headless Chrome for screenshots.

**Spec:** `docs/superpowers/specs/2026-10-02-site-redesign-design.md`

## Global Constraints

- Body font Source Serif 4 (400, 400 italic, 600); headings, nav, buttons and metadata in Inter (400, 500, 600).
- Light tokens: background `#fbfaf7`, text `#1f2328`, muted `#5b6470`, accent `#0f6e6e`, divider `rgba(0,0,0,0.08)`.
- Dark tokens: background `#15181c`, text `#e6e6e3`, muted `#9aa3ad`, accent `#5fb3b3`, divider `rgba(255,255,255,0.10)`.
- `max_width` 760px. Body 1.0625rem / 1.7. h1 2rem, h2 1.375rem, h3 1.125rem, Inter 600, letter-spacing -0.01em.
- Homepage body text 250 words or fewer, not counting the News list.
- No `####` headings in `_pages/about.md` or `_pages/research.md`.
- Nothing about prefill-decode disaggregation anywhere in the built site.
- Do not edit `_layouts/` or `_includes/`.
- Per the user's standing instruction: every commit is pushed in the same step (`git push`).
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>`.

## Review Focus

1. **Dark mode from both the toggle and system preference.** al-folio sets `html[data-theme="dark"]` in both cases, so dark tokens must live in that block. Task 6 takes dark screenshots with a forced dark system preference.
2. **375px phone width.** The profile photo must stack, the navbar must collapse, and there must be no horizontal scroll. Task 6 takes mobile screenshots of home, research and publications.
3. **Label-style h2 leaking into blog posts.** Blog posts use `<article class="post-content">` and must keep normal headings. Task 2's check greps the selector; Task 6 screenshots a blog post.
4. **Blog figures after the accent change.** `_blog-figs.scss` figures read theme variables. Task 6 screenshots the "three numbers" post in light and dark.
5. **Renamed or missing post breaks `{% post_url %}`.** Home and research link to the post through `post_url`, which fails the build if the file is renamed. Every task's build step catches this.

---

## File Structure

| File | Responsibility |
|---|---|
| `bin/check-redesign.sh` (new) | Assertions on `_site/` and `_pages/` that encode the spec; used as each task's test |
| `_sass/_refined.scss` (new) | Every new visual rule: fonts, scale, labels, links, profile, publication pills |
| `assets/css/main.scss` | One added `@use "refined";` line |
| `_sass/_themes.scss` | Token values only (light `:root` and `html[data-theme="dark"]`) |
| `_config.yml` | `max_width`, Google Fonts URL, `bib_search` |
| `_pages/research.md` (new) | Long-form research text |
| `_pages/about.md` | Short homepage |
| `_pages/cv.md`, `talks.md`, `blog.md`, `now.md`, `publications.md` | Nav flags/order only |
| `_bibliography/papers.bib` | `abbr={Preprint}` on `ramani2026queueing` |
| `docs/superpowers/specs/2026-10-02-site-redesign-design.md` | Record the news-list deviation |

---

### Task 1: Spec check script

**Files:**
- Create: `bin/check-redesign.sh`

**Interfaces:**
- Produces: `bin/check-redesign.sh`, run from repo root after `bundle exec jekyll build`. It prints `ok` or `FAIL` per check and exits with the number of failures. Later tasks name checks by their exact label below.

- [ ] **Step 1: Write the script**

```bash
#!/usr/bin/env bash
# Checks the built _site against docs/superpowers/specs/2026-10-02-site-redesign-design.md.
# Run from anywhere after `bundle exec jekyll build`.
set -uo pipefail
cd "$(dirname "$0")/.."
S=_site
fails=0

check() {
  if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi
}

home_words() {
  python3 - <<'EOF'
import re
body = open("_pages/about.md").read().split("---", 2)[2]
body = re.sub(r"^## News\n.*?(?=^## |\Z)", "", body, flags=re.M | re.S)
body = re.sub(r"\]\([^)]*\)", "]", body)
body = re.sub(r"\{%.*?%\}", "", body)
print(len(re.findall(r"[A-Za-z0-9][A-Za-z0-9'’.-]*", body)))
EOF
}

# Task 2: visual system
check "fonts loaded"          'grep -q "family=Source+Serif+4" $S/index.html && grep -q "family=Inter" $S/index.html'
check "light accent token"    'grep -q "#0f6e6e" $S/assets/css/main.css'
check "dark accent token"     'grep -q "#5fb3b3" $S/assets/css/main.css'
check "760px column"          'grep -q "760px" $S/assets/css/main.css'
check "labels skip blog posts" 'grep -q "article:not(.post-content) h2" _sass/_refined.scss'

# Task 3: research page and nav
check "research page built"   '[ -f $S/research/index.html ]'
check "nav has research"      'grep -q "href=\"/research/\"" $S/index.html'
check "nav has cv"            'grep -q "href=\"/cv/\"" $S/index.html'
check "research keeps PhD"    'grep -q "lazy reading is timely" $S/research/index.html && grep -q "Read-Copy-Update" $S/research/index.html && grep -q "Thesis_VR.pdf" $S/research/index.html'
check "research keeps IBM"    'grep -q "2609.20957" $S/research/index.html && grep -q "BLIS" $S/research/index.html'
check "no #### headings"      '! grep -q "^####" _pages/about.md _pages/research.md'

# Task 4: homepage
check "home <= 250 words"     '[ "$(home_words)" -le 250 ]'
check "home links research"   'grep -q "href=\"/research/\">More on my research" $S/index.html'
check "home news"             'grep -q "2609.20957" $S/index.html && grep -q "IEEE CLOUD 2026" $S/index.html'
check "home selected papers"  'grep -q "Lock-Based or Lock-Less" $S/index.html'

# Task 5: publications
check "no bib search box"     '! grep -q "id=\"bibsearch\"" $S/publications/index.html'
check "preprint badge"        'grep -q "Preprint" $S/publications/index.html'

# Spec-wide
check "no disaggregation"     '! grep -rqi disaggregat $S --include="*.html"'

echo "$fails failure(s)"
exit "$fails"
```

- [ ] **Step 2: Build and run it to see the baseline fail**

Run: `chmod +x bin/check-redesign.sh && bundle exec jekyll build -q && bin/check-redesign.sh`
Expected: only `no disaggregation` passes. Everything else FAILs, including `home selected papers`, because `selected_papers` is still `false`. The exit code is non-zero.

- [ ] **Step 3: Commit and push**

```bash
git add bin/check-redesign.sh
git commit -m "Add redesign spec check script

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
git push
```

---

### Task 2: Visual system

**Files:**
- Create: `_sass/_refined.scss`
- Modify: `assets/css/main.scss` (append one line after `@use "blog-figs";`)
- Modify: `_sass/_themes.scss` (token lines inside `:root` near lines 9–20 and `html[data-theme="dark"]` near lines 79–90)
- Modify: `_config.yml` (`max_width` line 62, `google_fonts.url.fonts` line 453)

**Interfaces:**
- Consumes: `bin/check-redesign.sh` from Task 1.
- Produces: CSS variables `--global-theme-color`, `--global-text-color-light` and `--global-divider-color` with the new values. Sass variables `$serif` and `$sans` exist only inside `_refined.scss`.

- [ ] **Step 1: Confirm the Task 2 checks fail**

Run: `bin/check-redesign.sh | grep -E "fonts|accent|760|labels"`
Expected: all five lines show `FAIL`.

- [ ] **Step 2: Update `_config.yml`**

Change `max_width: 930px` to:

```yaml
max_width: 760px
```

Replace the `fonts:` value under `third_party_libraries.google_fonts.url` with:

```yaml
      fonts: "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Source+Serif+4:ital,wght@0,400;0,600;1,400&family=Material+Icons&display=swap"
```

- [ ] **Step 3: Update theme tokens in `_sass/_themes.scss`**

In the `:root` block, set these lines (keep every other line as it is):

```scss
  --global-bg-color: #fbfaf7;
  --global-text-color: #1f2328;
  --global-text-color-light: #5b6470;
  --global-theme-color: #0f6e6e;
  --global-hover-color: #0f6e6e;
  --global-footer-bg-color: #fbfaf7;
  --global-footer-text-color: #5b6470;
  --global-footer-link-color: #0f6e6e;
  --global-divider-color: rgba(0, 0, 0, 0.08);
```

In the `html[data-theme="dark"]` block, set:

```scss
  --global-bg-color: #15181c;
  --global-text-color: #e6e6e3;
  --global-text-color-light: #9aa3ad;
  --global-theme-color: #5fb3b3;
  --global-hover-color: #5fb3b3;
  --global-footer-bg-color: #15181c;
  --global-footer-text-color: #9aa3ad;
  --global-footer-link-color: #5fb3b3;
  --global-divider-color: rgba(255, 255, 255, 0.1);
```

Leave `--global-hover-text-color` unchanged. It is white text on the accent background, which works on both teals.

- [ ] **Step 4: Create `_sass/_refined.scss`**

```scss
/*******************************************************************************
 * Refined layer: typography, rhythm and accents on top of al-folio.
 * Loaded last in main.scss so it overrides theme defaults.
 ******************************************************************************/

$serif: "Source Serif 4", Georgia, "Times New Roman", serif;
$sans: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;

body {
  font-family: $serif;
  font-size: 1.0625rem;
  line-height: 1.7;
  background-color: var(--global-bg-color);
}

h1,
h2,
h3,
h4,
h5,
h6,
.navbar,
.btn,
.badge,
.post-meta,
.post-tags,
.post-description,
.desc,
footer {
  font-family: $sans;
}

h1,
h2,
h3 {
  font-weight: 600;
  letter-spacing: -0.01em;
}

.post-title {
  font-size: 2rem;
}

h2 {
  font-size: 1.375rem;
}

h3 {
  font-size: 1.125rem;
  margin-top: 2rem;
}

.post-header .desc,
.post-description {
  color: var(--global-text-color-light);
  font-size: 0.95rem;
}

// Page section headers are quiet labels. Blog posts (article.post-content)
// keep normal headings.
.post > article:not(.post-content) h2 {
  margin-top: 3rem;
  padding-bottom: 0.4rem;
  border-bottom: 1px solid var(--global-divider-color);
  font-size: 0.8rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--global-text-color-light);

  a {
    color: inherit;
  }
}

a {
  color: var(--global-theme-color);
  text-decoration: none;

  &:hover {
    color: var(--global-hover-color);
    text-decoration: underline;
    text-decoration-thickness: 1px;
    text-underline-offset: 3px;
  }
}

.navbar {
  box-shadow: none;
  border-bottom: 1px solid var(--global-divider-color);

  .nav-link {
    font-size: 0.9rem;
    font-weight: 500;
  }
}

.profile {
  width: 180px;

  img {
    border-radius: 4px;
    box-shadow: none !important;
  }
}

@media (max-width: 575.98px) {
  .profile {
    float: none !important;
    width: 100%;
    max-width: 220px;
    margin: 0 auto 1.5rem;
  }
}

footer {
  border-top: 1px solid var(--global-divider-color);
}

.publications {
  .abbr .badge {
    background-color: var(--global-theme-color) !important;
    font-weight: 500;
  }

  .links a.btn {
    font-family: $sans;
    font-size: 0.75rem;
    color: var(--global-theme-color);
    border: 1px solid var(--global-theme-color);
    border-radius: 999px;
    padding: 0.1rem 0.6rem;
    box-shadow: none;

    &:hover {
      color: var(--global-hover-text-color);
      background-color: var(--global-theme-color);
      text-decoration: none;
    }
  }
}
```

- [ ] **Step 5: Load the partial in `assets/css/main.scss`**

After the line `@use "blog-figs";` append:

```scss
@use "refined";
```

- [ ] **Step 6: Build and run the checks**

Run: `bundle exec jekyll build -q && bin/check-redesign.sh | grep -E "fonts|accent|760|labels"`
Expected: all five lines show `ok`. The build prints no Sass errors.

- [ ] **Step 7: Commit and push**

```bash
git add _sass/_refined.scss _sass/_themes.scss assets/css/main.scss _config.yml
git commit -m "Apply refined visual system: serif body, teal accent, narrower column

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
git push
```

---

### Task 3: Research page and navigation

**Files:**
- Create: `_pages/research.md`
- Modify: front matter only of `_pages/publications.md`, `talks.md`, `blog.md`, `now.md`, `cv.md`

**Interfaces:**
- Consumes: the post `_posts/2026-07-18-an-llm-server-in-three-numbers.md` (through `post_url`).
- Produces: the URL `/research/` and the nav order: about, research 2, publications 3, talks 4, blog 5, now 6, cv 7. Task 4 links to `/research/`.

- [ ] **Step 1: Confirm the Task 3 checks fail**

Run: `bin/check-redesign.sh | grep -E "research|nav has|####"`
Expected: `research page built`, `nav has research`, `nav has cv`, `research keeps PhD`, `research keeps IBM` and `no #### headings` all FAIL. `no ####` fails because `research.md` doesn't exist yet and `about.md` has `####`.

- [ ] **Step 2: Create `_pages/research.md`**

```markdown
---
layout: page
title: research
permalink: /research/
description: Performance models for LLM inference serving at IBM, and Age of Information in computing systems from my PhD.
nav: true
nav_order: 2
---

## At IBM Research

Since October 2024 I have worked on large language model inference serving at production scale. An inference deployment is a producer-consumer system: requests arrive at unpredictable rates, accelerators are an expensive shared resource, and latency targets are Service Level Objectives rather than soft preferences. The job is to schedule and scale it so those targets hold without stranding capacity.

I am co-architect of the [Workload Variant Autoscaler](https://github.com/llm-d/llm-d-workload-variant-autoscaler) (WVA) for the open-source [llm-d](https://github.com/llm-d) project, a horizontal autoscaler that reasons about prefill and decode behavior instead of treating inference as a generic web service.

### Modeling an inference server

An LLM server handles each request in two phases. Prefill runs one forward pass over the whole prompt, builds the key-value (KV) cache, and emits the first token; it is compute-bound. Decode then produces tokens one at a time, reading the full KV cache on every step; it is memory-bandwidth-bound. With continuous batching, both kinds of work share each forward pass and the batch composition shifts constantly. The two latencies users feel follow from this split: Time-to-First-Token (TTFT), set by queueing and prefill, and Inter-Token Latency (ITL), set by per-iteration decode work and cache size.

With Asser N. Tantawi, I developed a tractable queueing model of this behavior. Three time-valued parameters describe a (model, GPU) pair. Mean-value analysis gives closed-form mean ITL and prefill latency, and a state-dependent birth-death Markov chain over batch size gives mean TTFT, with chunked prefill as the general case. Against vLLM on an H100 GPU with Llama-3.1-8B and Qwen2.5-14B, mean ITL error is about 5 and 8 percent and mean TTFT error 14 and 16 percent under light to moderate load. Because the parameters can be fitted online from observed latencies, the model drives an autoscaling controller that tracked a fourfold load ramp on an OpenShift H100 cluster while missing the latency target in only 7 of 127 control cycles.

[Paper (arXiv:2609.20957)](https://arxiv.org/abs/2609.20957) · [Blog post]({% post_url 2026-07-18-an-llm-server-in-three-numbers %}) · [Analyzer code](https://github.com/llm-d/llm-d-workload-variant-autoscaler/tree/main/internal/engines/analyzers/queueingmodel)

### Analysis, simulation, and agentic search

I also pair analytical models with the AI-Driven Research for Systems (ADRS) methodology of [Liu et al.](https://arxiv.org/abs/2510.06189) An agentic search loop proposes scheduling and autoscaling algorithms, a high-fidelity simulator evaluates them, and my models supply provable throughput and latency guarantees for what the search finds. The team's open-source pieces are [Nous](https://github.com/AI-native-Systems-Research/agentic-strategy-evolution), a hypothesis-driven experimentation framework, and [BLIS](https://github.com/inference-sim/inference-sim), the simulator Nous uses to evaluate candidates.

## PhD research

I completed my PhD at Rutgers University in 2024, advised by [Professor Roy D. Yates](https://www.winlab.rutgers.edu/~ryates/). My dissertation, [_Storing, Retrieving, and Processing Updates: A Timeliness Perspective_](/assets/pdf/Thesis_VR.pdf), studies the Age of Information (AoI): the time elapsed since the newest available update was generated at its source. Applications such as autonomous driving and remote telesurgery need information that is fresh where decisions are made, not just low latency. A car in city traffic moves about a centimeter every millisecond, so a position update a few milliseconds late describes a world that no longer exists.

Most AoI work follows updates through communication channels. My thesis follows them through shared memory, where a writer publishes time-stamped updates and a reader samples them for a client's downstream computation. The asynchronous interaction between the two raises three problems.

### Optimizing memory access

When should a reader sample shared memory? With a fixed cost per read in discrete time, I formulate a Markov decision problem and prove the optimal policy is stationary, deterministic, and threshold-type, with the threshold and average cost in closed form. When the reader cannot see the age of the update in memory, heuristics approach the known-state lower bound in realistic regimes. In continuous time, with the client as a decision process with random computation time, the main result is that _lazy reading is timely_: idling for a tuned interval before the next read lowers average age at the monitor.

### Synchronization primitives and freshness

In a packet forwarder, a writer records each mobile user's current address in a Forwarding Information Base, and the forwarder reads it to address application updates. A misaddressed update is lost, so the freshness of location updates sets the freshness of application updates. Using a Stochastic Hybrid System framework, I compare the lock-based Readers-Writer Lock (RWL) with the lock-free Read-Copy-Update (RCU). RWL delivers fresher updates at high location-update rates, and RCU at low rates. A separate result shows that with finite read time and a finite read-request rate, the number of live RCU copies stays bounded, answering the concern that lock-free synchronization can grow memory without limit.

### Timely and energy-efficient multi-step processing

Some outputs need several sequential computation stages. They can run pipelined, with one processor per stage, or in parallel, with each processor running the full stack. Both waste compute: pipelines preempt or idle, and parallel workers finish updates that fresher ones have already overtaken. I formulate the age-power trade-off, find the configuration that minimizes age under a fixed power budget, and characterize the optimal service-rate allocation across stages. Synchronous sequential execution generally beats its asynchronous variant, and parallel processing tends to beat pipelining on AoI.

See [publications](/publications/) for the papers behind each chapter.
```

- [ ] **Step 3: Reorder the nav**

Set these front-matter values and change nothing else in each file:

| File | `nav` | `nav_order` |
|---|---|---|
| `_pages/publications.md` | true | 3 |
| `_pages/talks.md` | true | 4 |
| `_pages/blog.md` | true | 5 |
| `_pages/now.md` | true | 6 |
| `_pages/cv.md` | true | 7 |

- [ ] **Step 4: Build and run the checks**

Run: `bundle exec jekyll build -q && bin/check-redesign.sh | grep -E "research|nav has|####"`
Expected: every line except `no #### headings` shows `ok`. That one still fails because `about.md` has `####`, and Task 4 fixes it.

- [ ] **Step 5: Confirm the nav order in the built HTML**

Run: `grep -o 'class="nav-link" href="[^"]*"' _site/index.html`
Expected order: `/`, `/research/`, `/publications/`, `/talks/`, `/blog/`, `/now/`, `/cv/`.

- [ ] **Step 6: Commit and push**

```bash
git add _pages/research.md _pages/publications.md _pages/talks.md _pages/blog.md _pages/now.md _pages/cv.md
git commit -m "Add research page; reorder nav and restore CV link

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
git push
```

---

### Task 4: Homepage rewrite

**Files:**
- Modify: `_pages/about.md` (whole file)
- Modify: `docs/superpowers/specs/2026-10-02-site-redesign-design.md` (the News item under "Home")

**Interfaces:**
- Consumes: `/research/` from Task 3; the `selected={true}` bib entries `ramani2026queueing`, `malvankar2026wva`, `abdelzaher2025bottlenecks` and `ramani2023locks`.

- [ ] **Step 1: Confirm the Task 4 checks fail**

Run: `bin/check-redesign.sh | grep -E "home|####"`
Expected: `home <= 250 words`, `home links research`, `home news` and `no #### headings` all FAIL.

- [ ] **Step 2: Replace `_pages/about.md`**

```markdown
---
layout: about
title: about
permalink: /
subtitle: Research Staff Member, IBM T. J. Watson Research Center

profile:
  align: right
  image: prof_pic.jpg
  image_circular: false
  more_info:

selected_papers: true
social: true

announcements:
  enabled: false

latest_posts:
  enabled: false
---

I am a Research Staff Member at IBM T. J. Watson Research Center in Yorktown Heights, New York. I work on performance modeling and analysis of computing systems. My current focus is scheduling and autoscaling large language model inference at production scale.

## Research

**Queueing models of LLM inference.** Three hardware parameters predict time to first token and inter-token latency closely enough to drive an autoscaler. [Paper](https://arxiv.org/abs/2609.20957) · [Blog post]({% post_url 2026-07-18-an-llm-server-in-three-numbers %})

**Autoscaling in llm-d.** I co-architected the Workload Variant Autoscaler, which sizes LLM inference deployments against latency targets. [Code](https://github.com/llm-d/llm-d-workload-variant-autoscaler)

**Age of Information.** My PhD at Rutgers (2024), with Roy Yates, on keeping data fresh as it is stored, retrieved, and processed. [Thesis](/assets/pdf/Thesis_VR.pdf)

[More on my research →](/research/)

## News

- **Sep 2026.** Preprint with Asser Tantawi on arXiv: [_An Approximate Queueing Model of LLM Inference Serving for SLO-Driven Autoscaling_](https://arxiv.org/abs/2609.20957).
- **2026.** WVA paper, _A Global Optimization Control Plane for llm-d_, to appear at IEEE CLOUD 2026.

Outside research, I follow professional road cycling closely ([what I'm watching now](/now/)) and play piano on occasion.
```

- [ ] **Step 3: Record the deviation in the spec**

In the spec's "Home" list, replace item 3 (the line starting `3. **News** (enable al-folio`, through `items are added only if the user supplies dates.`) with:

```markdown
3. **News**: a hand-written Markdown list in `about.md` (most recent first, at
   most 4 items). al-folio's built-in announcements block was not used because
   its heading links to `/news/`, which this site does not have, and fixing that
   would mean editing the layout.
```

- [ ] **Step 4: Build and run the full check**

Run: `bundle exec jekyll build -q && bin/check-redesign.sh`
Expected: every check except `no bib search box` and `preprint badge` shows `ok`. Task 5 handles those two.

- [ ] **Step 5: Commit and push**

```bash
git add _pages/about.md docs/superpowers/specs/2026-10-02-site-redesign-design.md
git commit -m "Rewrite homepage as a short landing page

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
git push
```

---

### Task 5: Publications

**Files:**
- Modify: `_config.yml:59` (`bib_search`)
- Modify: `_bibliography/papers.bib` (the `ramani2026queueing` entry)

**Interfaces:**
- Consumes: al-folio's `bib.liquid`, which renders `entry.abbr` as a badge in the left column.

- [ ] **Step 1: Confirm the Task 5 checks fail**

Run: `bin/check-redesign.sh | grep -E "bib search|preprint"`
Expected: both FAIL.

- [ ] **Step 2: Turn off bib search**

In `_config.yml` change `bib_search: true` to:

```yaml
bib_search: false
```

- [ ] **Step 3: Add the badge**

In `_bibliography/papers.bib`, inside `@article{ramani2026queueing,`, add this line after the `year={2026},` line:

```bibtex
  abbr={Preprint},
```

- [ ] **Step 4: Build and run the full check**

Run: `bundle exec jekyll build -q && bin/check-redesign.sh`
Expected: every check shows `ok`, ending with `0 failure(s)`.

- [ ] **Step 5: Commit and push**

```bash
git add _config.yml _bibliography/papers.bib
git commit -m "Publications: preprint badge, drop search box

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
git push
```

---

### Task 6: Visual verification

**Files:** none. Fix-ups go in `_sass/_refined.scss` only.

- [ ] **Step 1: Serve the site locally**

Run in the background: `bundle exec jekyll serve --port 4000`
Wait until `curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/` prints `200`.

- [ ] **Step 2: Take screenshots**

```bash
mkdir -p /tmp/shots
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
POST=$(grep -o 'href="/blog/2026/[^"]*three-numbers[^"]*"' _site/index.html | head -1 | cut -d'"' -f2)
for page in "home:/" "research:/research/" "pubs:/publications/" "post:$POST" "now:/now/"; do
  name=${page%%:*}; path=${page#*:}
  "$CHROME" --headless=new --hide-scrollbars --window-size=1280,2200 \
    --screenshot=/tmp/shots/$name-desktop-light.png "http://localhost:4000$path"
  "$CHROME" --headless=new --hide-scrollbars --window-size=1280,2200 \
    --force-dark-mode --blink-settings=preferredColorScheme=0 \
    --screenshot=/tmp/shots/$name-desktop-dark.png "http://localhost:4000$path"
  "$CHROME" --headless=new --hide-scrollbars --window-size=375,2400 \
    --screenshot=/tmp/shots/$name-mobile-light.png "http://localhost:4000$path"
done
ls /tmp/shots
```

Expected: 15 PNG files.

- [ ] **Step 3: Review each screenshot against this checklist**

Open each image with the Read tool.
- Home: serif body, Inter headings, small uppercase RESEARCH / NEWS / SELECTED PUBLICATIONS labels with hairlines, photo about 180px on the right, teal links.
- Dark: background `#15181c`, light text, light-teal links. No leftover purple or cyan.
- Mobile: photo centered above the text, nav collapsed to the hamburger menu, no text cut off at the right edge.
- Blog post: headings at normal size, not uppercase labels. Figures readable in light and dark.
- Publications: year headers as labels, "Preprint" badge in teal, rounded outline buttons.

- [ ] **Step 4: Fix any problem in `_sass/_refined.scss`, then rebuild, re-check and re-screenshot**

If the profile-width override loses on specificity, for example, change `.profile` to `.post .profile`. Run `bundle exec jekyll build -q && bin/check-redesign.sh` and repeat Step 2 for the affected page.

- [ ] **Step 5: Stop the server, commit and push any fix-ups**

```bash
git add _sass/_refined.scss
git diff --cached --quiet || git commit -m "Refine styles after visual review

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
git push
```

- [ ] **Step 6: Watch the deploy**

Run: `gh run list --limit 3`
Expected: the latest `Deploy site` run for the final commit finishes with `success`. If it fails, read `gh run view --log-failed` before changing anything.
