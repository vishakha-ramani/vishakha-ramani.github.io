---
layout: post
title: "Freshness has a memory bill"
date: 2026-07-17
categories: research
tags: age-of-information rcu shared-memory
thumbnail: assets/img/blog/thumb-memory-bill.svg
description: "Part three of a series on my PhD work. How much memory Read-Copy-Update spends to keep information fresh, and why the bill stays bounded."
related_posts: false
---

{% include series_nav.liquid part=3 %}

Consider a phone running visual SLAM, the technique that lets a device build a map of its surroundings while tracking its own position inside that map. Camera frames arrive continuously, and concurrent modules for tracking, mapping, and optimization all work against one shared global map in real time. Read-Copy-Update is an attractive way to coordinate them, because a module can pin the current version of the map and compute against it without ever blocking the writer. But every pinned version is a copy sitting in the memory of a device that does not have much to spare.

The first two posts in this series established that RCU often delivers fresher information than a lock, and that the advantage shows up on real hardware. Both also hinted at the price, because RCU buys its freshness with copies. A writer publishes a new version, readers still inside their critical sections keep the old one alive, and nothing can be reclaimed until the last of those readers lets go. In `Age-Memory Trade-off in Read-Copy-Update`, again with Jiachen Chen and Roy Yates, we asked whether that price is bounded. If updates keep arriving and old versions must survive their readers, can the number of retained copies grow without limit?

We made the writer as aggressive as the mechanism allows. In the model, it begins writing the next update the instant it publishes the previous one, with exponential write times, so fresh versions are published as a Poisson process at rate $$\alpha$$. This is deliberately the worst case for memory. Read requests arrive as a Poisson process at rate $$\lambda$$, and each holds its version for an exponentially distributed read time with mean $$1/\mu$$, and a version is reclaimed only when its last reader finishes. One subtlety makes the analysis more than a textbook exercise. How long a version stays current depends on when the next update happens to be published, so the population of live versions is not the $$M/M/\infty$$ queue it superficially resembles.

<figure class="blog-fig">
  {% include blog/figs/p3-versions.svg %}
  <figcaption>RCU&rsquo;s version chain. Readers keep old copies alive through their grace periods while the age of the current update follows a sawtooth. Illustrative.</figcaption>
</figure>

Two results summarize the paper. First, the average age of the current update in memory is $$2/\alpha$$ for write rate $$\alpha$$, so a faster writer keeps memory fresher, with no surprise there. Second, the average number of updates held in the system never exceeds $$1 + \lambda/\mu$$, where $$\lambda$$ is the read request rate and $$1/\mu$$ is the mean read time, no matter how fast the writer publishes. Writing faster makes information fresher without blowing up the version count. The bound also has a clean interpretation in the limit of an infinitely fast writer. Each read request then effectively pins its own private version, the pinned versions do form an $$M/M/\infty$$ queue, and their number is Poisson with mean $$\lambda/\mu$$. Add the single current version and the bound is met exactly.

<figure class="blog-fig">
  {% include blog/figs/p3-tradeoff.svg %}
  <figcaption>The trade-off in one curve, after the paper&rsquo;s numerical evaluation. Faster writing makes memory fresher while the version count approaches its ceiling.</figcaption>
</figure>

<div class="key-result">Freshness has a bounded bill. However fast the writer publishes, the average number of retained versions never exceeds 1 + &#955;/&#956;.</div>

The satisfying part is where the bill lands. Memory consumption in RCU is governed by the read side, not the write side. Slow reads and frequent read requests are what hold versions in memory, so a system that needs to cap RCU's footprint should shorten its read-side critical sections or consolidate its read requests, rather than throttle the writer and pay for the savings in staleness.

Taken together, the three papers form one argument. Synchronization primitives are not interchangeable implementation details, because they decide which version of the truth a reader observes. Their effects on freshness are measurable in a real forwarder, alongside timeliness penalties that throughput benchmarks never reveal. And the freshest mechanism carries a resource cost that can be quantified and belongs in the model next to the age it buys.

I now work on performance modeling and analysis for large language model inference at IBM Research, and the same accounting follows me there. An inference server holds key-value cache in GPU memory so that tokens keep streaming on time, and the question of how much memory a latency target costs is asked in gigabytes rather than table versions. The setting has changed, but the tradeoff has not.

{% include series_nav.liquid part=3 position="footer" %}

Vishakha Ramani is a Research Staff Member at IBM Research. She works on performance modeling and analysis of large-scale computing systems, most recently for large language model inference. She holds a PhD from Rutgers University, where she studied the timeliness of information in computing systems with Prof. Roy Yates. [Google Scholar](https://scholar.google.com/citations?user=eJg7gqwAAAAJ) · [LinkedIn](https://www.linkedin.com/in/vishakha-ramani/)
