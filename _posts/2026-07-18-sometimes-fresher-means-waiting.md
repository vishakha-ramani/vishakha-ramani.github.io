---
layout: post
title: "Sometimes fresher means waiting"
date: 2026-07-18 00:01
categories: research
tags: age-of-information update-processing queueing
thumbnail: assets/img/blog/thumb-fresher-waiting.svg
description: "Part one of a second series on my PhD work. Why a decision process that reads shared data and computes on it should sometimes sit idle before reading again."
related_posts: false
---

{% include series_nav.liquid series="timing" part=1 %}

Picture the compute node behind a smart intersection. Cameras and roadside sensors publish measurements continuously. An analytics process reads the latest data, spends some time computing a safety decision, and delivers the result to a monitor that acts on it. The monitor does not care how busy the pipeline was. It cares how old the information behind the current decision is by the time that decision arrives.

In `Timely Processing of Updates from Multiple Sources`, written with Ivan Seskar and Roy Yates, we modeled this loop as a publish-subscribe system. Two independent sources push time-stamped updates through a writer into shared memory, with Read-Copy-Update arbitrating between writer and reader, the same mechanism the [first series](/blog/2026/a-lock-can-make-data-fresher/) dissected. A decision process subscribes by reading the latest pair of source updates, computes on it for a random time, and sends the derived decision update onward. Then it faces its only real choice. Read again immediately, or wait a while first?

<figure class="blog-fig">
  {% include blog/figs/s2-pipeline.svg %}
  <figcaption>The publish-subscribe loop. Sources publish on their own schedule, the decision process chooses only when to read and compute, and the monitor receives the finished decision updates.</figcaption>
</figure>

Reading again immediately is the zero-wait policy, and it feels obviously right. The processor never idles, every cycle is spent turning data into decisions, and any deliberate delay looks like negligence. The paper shows that this instinct is wrong, and it shows exactly why.

The analysis tracks three coupled age processes. There is the age of the source updates sitting in memory, the age of the sample the decision process is computing on, and the age of the decision update at the monitor. The decision process controls none of the publishing. Sources update memory on their own schedule, so laziness cannot make the inputs fresher. What it can do is change which inputs get sampled and when the computation lands.

The cleanest result in the paper is a separation. For any waiting rule that depends only on the previous computation time, the average age at the monitor equals the average age at the reader's input plus exactly the mean computation time. The output lags the input by $$\mathrm{E}[T]$$, no matter how clever or lazy the reading policy is. That lag is a fixed tax, and it means the whole game is minimizing the input age. This reduces our problem to the classic update-or-wait problem, whose solution has a known shape. After a long computation, read again at once. After a short one, wait until a set amount of time has passed since the last read.

<figure class="blog-fig">
  {% include blog/figs/s2-lag.svg %}
  <figcaption>The separation result. Whatever the reading policy, the average age at the monitor sits exactly one mean computation time above the average age at the reader&rsquo;s input. Illustrative.</figcaption>
</figure>

Whether waiting is worth much depends on the variance of the computation time. When computation times are exponential, the gains are modest. When they are log-normal with a heavy tail, which is much closer to how real compute behaves on a shared machine, zero-wait becomes clearly suboptimal. In our numerical evaluations at the heaviest tail we tested, the best lazy policy cut the average age at the monitor by roughly a third relative to reading at full tilt, and the gap widens as the tail grows. The intuition is that a long computation already delivered a stale result, and immediately grabbing the next sample tends to repeat the mistake. Waiting lets the memory refresh so the next computation starts from better inputs.

<figure class="blog-fig">
  {% include blog/figs/s2-variance.svg %}
  <figcaption>An illustrative version of the paper&rsquo;s numerical results. With low variance in computation times, zero-wait is nearly optimal. With heavy tails, the best lazy policy is clearly better.</figcaption>
</figure>

<div class="key-result">However the reader schedules its reads, the monitor lags the input by exactly the mean computation time. All a policy can improve is the input age, and under heavy-tailed computation times lazy reading improved it by roughly a third.</div>

The memory side of the analysis produced two findings worth keeping. Because the writer in our model holds no queue, pushing updates at a higher total rate only helps freshness. And the max-age of a sampled pair is penalized by asymmetry between the sources. A pair is only as fresh as its stalest member, so one slow sensor quietly ages every decision computed from the pair.

The lesson I took from this paper is that utilization and timeliness are different objectives that only look aligned. A processor that never rests can serve its monitor worse than one that waits on purpose. But the reader in this model was blind. It never looked at the age of what was in memory, only at its own clock. Give the reader eyes and a price per read, and you can ask a sharper question. Exactly when should it read? That is the [second post](/blog/2026/the-best-time-to-read-memory/) in this series.

{% include series_nav.liquid series="timing" part=1 position="footer" %}

Vishakha Ramani is a Research Staff Member at IBM Research. She works on performance modeling and analysis of large-scale computing systems, most recently for large language model inference. She holds a PhD from Rutgers University, where she studied the timeliness of information in computing systems with Prof. Roy Yates. [Google Scholar](https://scholar.google.com/citations?user=eJg7gqwAAAAJ) · [LinkedIn](https://www.linkedin.com/in/vishakha-ramani/)
