---
layout: post
title: "When a pipeline should stop working"
date: 2026-07-18 00:03
categories: research
tags: age-of-information queueing performance-modeling energy
thumbnail: assets/img/blog/thumb-pipeline-power.svg
description: "Part three of a second series on my PhD work. In multi-step update processing, busy servers can waste power on results that make no one better informed."
related_posts: false
---

{% include series_nav.liquid series="timing" part=3 %}

An object detector does not produce answers in one motion. A camera frame is pre-processed, features are extracted, and only then does classification yield something a decision can act on. Augmented reality and smart-city applications offload exactly this kind of work to nearby edge nodes, and the result is only useful if it is still current when it arrives. Multi-step processing is everywhere in real-time systems, yet the freshness literature had largely treated computation as a single act.

In `Timely and Energy-Efficient Multi-Step Update Processing`, written with Ivan Seskar and Roy Yates, we studied two-step processing as the fundamental building block. Two servers can be arranged in series, each owning one step of a pipeline, or in parallel, each running both steps independently. The judge of every arrangement is the age of information at the monitor receiving the finished updates. The constraint that makes the problem interesting is power.

<figure class="blog-fig">
  {% include blog/figs/s2-arch.svg %}
  <figcaption>The two arrangements. In series, each server owns one processing step. In parallel, each server runs both steps and the monitor keeps whichever finished update is freshest.</figcaption>
</figure>

The power model is where the numbers get vivid. Dynamic power in CMOS processors follows an alpha-power law, and with the technology exponent we use, power grows as the fifth power of processing speed. Running a step twice as fast costs roughly thirty two times the power. At that exchange rate, no one can afford to buy freshness with raw speed alone. The budget has to be spent where it changes what the monitor knows.

<figure class="blog-fig">
  {% include blog/figs/s2-power.svg %}
  <figcaption>The alpha-power law with exponent five. Doubling a step&rsquo;s speed multiplies its power draw by about thirty two.</figcaption>
</figure>

That framing exposes a phenomenon we call wasted power, which is work that never reduces the age at the monitor. It comes in several flavors. In parallel setups, one server can labor to finish an update while the other has already delivered a fresher one, making the first server's effort worthless on arrival. In series setups, an update can be preempted or discarded mid-pipeline, taking the energy already spent on it along. Even idleness is a form of waste, capacity that could have been informing the monitor and was not. A pipeline can be fully busy and still be spending watts on information that will land too late to matter.

<figure class="blog-fig">
  {% include blog/figs/s2-waste.svg %}
  <figcaption>Wasted power in a parallel setup. Once the faster server delivers, everything the slower server does for its older update is spent for nothing. Illustrative.</figcaption>
</figure>

We analyzed a family of concrete designs with stochastic hybrid systems. For series, four disciplines that differ in what happens when a fresh update arrives at a busy second server, ranging from preempting the update in service to blocking new arrivals entirely to a synchronous mode where a new update starts only when both servers are idle. For parallel, three policies, from fully independent servers to a coordinated policy where a server abandons stale work when its twin gets ahead, to a policy where servers share intermediate results and move through both steps together. The parallel analysis needed a twist on the standard machinery, because with independent servers not every delivery is useful. The monitor keeps the freshest update it has seen, so the analysis has to track minimums of ages rather than ages alone.

Then we asked the optimization question. Given a fixed power budget, how fast should each step run? Everything reduces to the ratio of the two service rates, and two findings hold across every model we studied. First, the second step should always run at least as fast as the first. For the preemptive series design the optimal ratio is about 0.85, and no model wants the first step faster. A slow exit stage is a bottleneck where nearly-finished updates sit and age, which is the worst place to save power. Second, the optimal ratio does not depend on the size of the budget. The right split between steps is structural, and more power should scale both steps up together.

The ranking of designs held surprises too. Among series disciplines, preemption in service wins, consistent with the freshness folklore that new should replace old. Less expected, synchronous service beats the asynchronous designs, meaning one update moving through the system at a time outperforms designs that keep more updates in flight only to discard or delay them. Parallel generally beats series, and the best design overall is the one where servers share intermediate results, converting two processors into what is effectively one faster, never-wasteful server. The common thread is that coordination is what eliminates wasted power. Servers that know what their peers have delivered do not burn watts on obsolete work.

<div class="key-result">At power that grows like the fifth power of speed, coordination beats raw speed. The best designs are the ones that never spend watts on updates the monitor has already outgrown.</div>

One caveat belongs in the record. These models use exponential processing times, where preempting a job loses no accumulated progress in expectation. With service times whose completion becomes more certain as work accumulates, killing a nearly-finished update is genuinely wasteful, and the clean definition of wasted power blurs. Extending the framework there is open work.

This paper closes the arc of the series, and of this half of my dissertation. Wait before computing when variance is high. Read at the moment the threshold says to. And stop working when the work cannot make anyone better informed. I now spend my days on inference systems that run a two-phase workload, a compute-heavy prefill followed by a memory-bound decode, under latency targets and power budgets. The vocabulary has changed from monitors and updates to tokens and service level objectives, but the accounting question underneath is the one this paper asked. Which watts are actually buying information?

{% include series_nav.liquid series="timing" part=3 position="footer" %}

Vishakha Ramani is a Research Staff Member at IBM Research. She works on performance modeling and analysis of large-scale computing systems, most recently for large language model inference. She holds a PhD from Rutgers University, where she studied the timeliness of information in computing systems with Prof. Roy Yates. [Google Scholar](https://scholar.google.com/citations?user=eJg7gqwAAAAJ) · [LinkedIn](https://www.linkedin.com/in/vishakha-ramani/)
