---
layout: post
title: "The router that measured freshness"
date: 2026-07-16
categories: research
tags: age-of-information networking experiments
thumbnail: assets/img/blog/thumb-router-freshness.svg
description: "Part two of a series on my PhD work. A DPDK packet forwarding testbed that measures the age of the information it delivers."
related_posts: false
---

{% include series_nav.liquid part=2 %}

There is a practical problem at the heart of measuring information freshness, and it nearly sank this experiment before it started. The age of a received update is the gap between the receiver's clock and the timestamp the sender stamped into the packet. On our testbed, NTP synchronizes clocks to about a millisecond, but the effects we needed to observe live at microsecond scale. Measured naively, the data would have been mostly clock error. Our workaround was to place the sender and the receiver on the same machine, so that every timestamp and every arrival referenced a single clock.

The experiment, described in `Timely Mobile Routing: An Experimental Study` with Jiachen Chen and Roy Yates, is the empirical companion to the analysis in [part one](/blog/2026/a-lock-can-make-data-fresher/). The stochastic models predicted that the choice between Read-Copy-Update and a Readers-Writer Lock changes the freshness of delivered information. We wanted to know whether that prediction survives contact with real hardware.

On the COSMOS testbed, we connected two machines over 25 Gbps links and built the forwarding application in DPDK, a kernel-bypass packet processing framework used in data centers and core routers. The source machine plays both the application server and 1000 mobile users at once. It emits two interleaved streams, data packets carrying timestamped application updates and control packets announcing user movements, with user popularity drawn from a Zipf distribution. The forwarder keeps its forwarding table in a hash table protected by either RCU or RWL. For each data packet it looks up the user, stamps the address it found, and sends the packet back to be scored as correctly delivered or misaddressed.

<figure class="blog-fig">
  {% include blog/figs/p2-testbed.svg %}
  <figcaption>The testbed. Sender and receiver share one machine and one clock so that microsecond ages are measurable, while the forwarder serves both packet streams around a shared hash table.</figcaption>
</figure>

Before testing any synchronization, we ran a baseline with a single immobile user and no table lookups at all, just to understand the packet path. Even that produced a lesson. Average age traced a U shape against sending rate. Up to about 1 million packets per second, sending faster made information fresher, as expected. Beyond roughly 4 million packets per second, age began climbing again. The culprit was batching. DPDK fills transmission rings in bursts to maximize throughput, and once the offered rate is high enough, packets start sharing batches and queueing in the ring while their information grows old. A framework tuned entirely for throughput was quietly taxing timeliness. The scale of the effect grew with the workload too. Average ages of 1 to 10 microseconds in the one-user baseline became 5 to 10 milliseconds once the experiment averaged over 1000 users.

<figure class="blog-fig">
  {% include blog/figs/p2-ucurve.svg %}
  <figcaption>An illustrative version of the baseline result. Age falls as updates come more often, then batching turns extra speed into queueing.</figcaption>
</figure>

<figure class="blog-fig">
  {% include blog/figs/p2-batching.svg %}
  <figcaption>Why the right half of the U bends upward. Below the knee every packet ships alone. Above it, packets age while a batch fills.</figcaption>
</figure>

The synchronization results matched the analysis where it counted. With one control packet per hundred data packets, RCU's cheap read side generally delivered fresher application updates than RWL at high sending rates, while at low rates the difference was negligible. When we raised the update ratio tenfold, both primitives struggled. The control ring backed up, the table lagged behind the users' actual movements, and misaddressed packets multiplied, with RWL misdelivering more than RCU. Under RWL, average age even reproduced the classic curve from updating theory, first falling with sending rate and then rising as the system congested. Updating should be fast, but not too fast.

<div class="key-result">RCU generally delivered fresher updates than RWL at high sending rates, and the biggest timeliness tax came from throughput-oriented batching rather than from locks.</div>

For me, the testbed's job was to keep the theory honest, and it did more than that. It confirmed the effect the models predicted, and it exposed penalties no clean model contained, like the batch admission delay. A forwarder can look excellent in packets per second while quietly delivering addresses that are no longer true, which is why freshness has to be measured directly rather than inferred from throughput or latency.

The experiments also made RCU's hidden cost tangible. Every RCU write creates another copy of the table entry, and stale copies linger until their readers finish, so the memory footprint grows and the implementation needs its own reclamation machinery. That raised a question the testbed could not answer. If a writer publishes updates as fast as it likes, does the pile of retained versions stay bounded? Answering that took another paper, and it is the subject of the [final post](/blog/2026/freshness-has-a-memory-bill/) in this series.

{% include series_nav.liquid part=2 position="footer" %}

Vishakha Ramani is a Research Staff Member at IBM Research. She works on performance modeling and analysis of large-scale computing systems, most recently for large language model inference. She holds a PhD from Rutgers University, where she studied the timeliness of information in computing systems with Prof. Roy Yates. [Google Scholar](https://scholar.google.com/citations?user=eJg7gqwAAAAJ) · [LinkedIn](https://www.linkedin.com/in/vishakha-ramani/)
