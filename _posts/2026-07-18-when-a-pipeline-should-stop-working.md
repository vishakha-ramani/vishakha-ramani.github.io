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

We built the series side as a family of four queueing disciplines, distinguished by what happens when the first server hands a fresh update to a second server that is still busy. In the fully preemptive design, the newcomer replaces the update in service and the displaced work is thrown away. A second design adds a waiting room holding exactly one update, where a newer arrival replaces whatever waits but never interrupts service. A third blocks instead, discarding fresh arrivals while the second server works. The fourth is synchronous, admitting a new update only when both servers stand idle, so a single update moves through the pipeline at a time. In every one of them the first server generates a fresh update the moment it finishes the previous one, so all the interesting congestion happens at the hand-off.

The parallel side is a spectrum of how much the two servers know about each other. At one end, each server runs both steps of its own update independently and delivers whenever it happens to finish. The coordinated alternating policy adds awareness, so both servers start on the same fresh update, and a server that falls behind abandons its work and restarts fresh once its twin carries a newer update into step two. The shared-intermediate policy goes furthest. Whichever server finishes step one first hands the intermediate result to both, they attack step two together, and the pair advances through the pipeline in lockstep. That last policy effectively fuses two processors into a single server that runs each step at twice the rate and never duplicates work.

<figure class="blog-fig">
  {% include blog/figs/s2-policies.svg %}
  <figcaption>The three parallel policies as a spectrum of coordination. The more each server knows about its twin, the less power it spends on updates that cannot help.</figcaption>
</figure>

Analytically, the series designs yield to the stochastic hybrid systems machinery that runs through the rest of my dissertation. The parallel designs forced an extension. When servers deliver independently, an arriving update only matters if it is fresher than what the monitor already holds, so the monitor's age is a running minimum over competing deliveries. Standard age bookkeeping cannot express that, and the fix is to carry auxiliary state variables that track minima of ages across servers, a device we adapted from the age-of-gossip literature. Getting those reset maps right is the technical heart of the paper's parallel results.

Then comes the optimization. Fix a power budget and ask how fast each step should run. Two structural facts make the problem tractable. In every model we analyzed, the average age at the monitor comes out as a function of the rate ratio $$\rho = \mu_1/\mu_2$$ divided by the step two rate $$\mu_2$$. And the power constraint caps $$\mu_2$$ through a quantity we called the power-weighted processor activity, which also depends only on $$\rho$$. A two-variable design problem therefore collapses to a one-dimensional search over the ratio. For the preemptive series design, the age is $$\tfrac{1}{\mu_2}(1 + \tfrac{1}{\rho})$$, and pushing the budget through the constraint puts the optimum at $$\rho^* \approx 0.846$$.

Two findings hold across every model we studied. The second step should always run at least as fast as the first, and no model wants the ratio above one. A slow exit stage is a bottleneck where nearly finished updates sit and age, which is the worst place to save power. And the optimal ratio does not depend on the size of the budget. The right split between the steps is structural, so extra power should scale both steps together rather than shift the balance.

<figure class="blog-fig">
  {% include blog/figs/s2-ratio.svg %}
  <figcaption>An illustrative version of the optimization result. More power lowers the whole curve, but the age-minimizing split between the steps stays at the same ratio, with step two always faster.</figcaption>
</figure>

The ranking of designs held surprises too. Among series disciplines, preemption in service wins, consistent with the freshness folklore that new should replace old, and the gap is not subtle. At the same service rates, the blocking design delivers exactly twice the average age of the preemptive one. Less expected, synchronous service beats the asynchronous designs, meaning one update moving through the system at a time outperforms designs that keep more in flight only to discard or delay them. Parallelism helps on top of that. Running the synchronous discipline on two independent servers, each on half the power budget, already beats its series counterpart, and the best design overall is the shared-intermediate policy. The common thread is that coordination is what eliminates wasted power. Servers that know what their peers have delivered do not burn watts on obsolete work.

<div class="key-result">At power that grows like the fifth power of speed, coordination beats raw speed. The best designs are the ones that never spend watts on updates the monitor has already outgrown.</div>

One caveat belongs in the record. These models use exponential processing times, where preempting a job loses no accumulated progress in expectation. With service times whose completion becomes more certain as work accumulates, killing a nearly-finished update is genuinely wasteful, and the clean definition of wasted power blurs. Extending the framework there is open work.

This paper closes the arc of the series, and of this half of my dissertation. Wait before computing when variance is high. Read at the moment the threshold says to. And stop working when the work cannot make anyone better informed. I now spend my days on inference systems that run a two-phase workload, a compute-heavy prefill followed by a memory-bound decode, under latency targets and power budgets. The vocabulary has changed from monitors and updates to tokens and service level objectives, but the accounting question underneath is the one this paper asked. Which watts are actually buying information?

{% include series_nav.liquid series="timing" part=3 position="footer" %}

Vishakha Ramani is a Research Staff Member at IBM Research. She works on performance modeling and analysis of large-scale computing systems, most recently for large language model inference. She holds a PhD from Rutgers University, where she studied the timeliness of information in computing systems with Prof. Roy Yates. [Google Scholar](https://scholar.google.com/citations?user=eJg7gqwAAAAJ) · [LinkedIn](https://www.linkedin.com/in/vishakha-ramani/)
