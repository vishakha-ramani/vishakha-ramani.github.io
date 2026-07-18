---
layout: post
title: "A lock can make data fresher"
date: 2026-07-15
categories: research
tags: age-of-information synchronization shared-memory
thumbnail: assets/img/blog/thumb-lock-fresher.svg
description: "Part one of a series on my PhD work. Comparing Read-Copy-Update and Readers-Writer locks when the metric is information freshness rather than throughput."
related_posts: false
---

{% include series_nav.liquid part=1 %}

Somewhere in the network sits a forwarder whose job is to keep up with a moving target. An application server streams updates to a mobile user, the user changes their point of attachment as they move, and the forwarder maintains a table that records where the user currently is. Every application packet passing through consults that table for an address.

Two processes contend for the table. A writer records fresh locations as the user moves. A reader looks up addresses so application packets can be delivered. When a read returns a stale location, the packet is sent to the wrong place, and in our model a misaddressed packet is simply lost. Whether the user receives timely updates therefore depends on a piece of machinery most performance models never mention. It depends on how the table is locked.

<figure class="blog-fig">
  {% include blog/figs/p1-system.svg %}
  <figcaption>The forwarding scenario. Location updates write to the table while app updates read it, and both streams meet at the FIB.</figcaption>
</figure>

In `Lock-based or Lock-less: Which Is Fresh?`, written with Jiachen Chen and Roy Yates during my PhD at Rutgers, we compared the two standard ways of protecting such a table. A Readers-Writer Lock enforces mutual exclusion, so a writer holding the lock blocks readers until it finishes. Read-Copy-Update takes the opposite view. Readers never block. The writer prepares a fresh copy of the data and atomically swaps in a pointer to it, while readers already in flight continue using the old version until they are done.

<figure class="blog-fig">
  {% include blog/figs/p1-mechanism.svg %}
  <figcaption>The same read request under both primitives. The lock delays the reader and delivers a fresh address. RCU serves the reader at once from the copy that is about to be replaced. Illustrative timelines.</figcaption>
</figure>

Benchmarked on throughput, this contest has a conventional winner. RCU is celebrated precisely because its read side is cheap, and operations per second favor it in read-mostly workloads. But our metric was not operations per second. We used the Age of Information, which measures how old a piece of information is at the moment it is delivered, and we tracked two quantities. One is the age of the location stored in the table. The other is the age of the application updates that actually reach the user.

The two ages are coupled through the table, so we modeled reader and writer together as a stochastic hybrid system. The discrete component is a five state Markov chain describing what the reader and writer are each doing, and the continuous component carries the age processes, which reset differently under RCU and RWL transitions. The payoff of the framework is a closed set of linear age balance equations whose solution gives the average ages without simulation.

The answer refused to pick a side. At low location update rates, RCU delivers fresher application updates, exactly as the throughput intuition suggests, because its light read side serves lookups quickly. At high location update rates, the ranking flips. The write lock in RWL, the very thing that makes readers wait, prevents a reader from walking away with an address that is in the middle of being replaced. RCU has no such restraint. Its reader cheerfully reads the old copy while the writer publishes the new one, and the packet goes out misaddressed. Blocking, usually cast as pure overhead, was acting as quality control.

<figure class="blog-fig">
  {% include blog/figs/p1-regime.svg %}
  <figcaption>An illustrative summary of the paper&rsquo;s numerical results. RCU wins when locations change rarely and RWL wins when they change often, while preemption reduces age under both.</figcaption>
</figure>

<div class="key-result">The freshest primitive is workload dependent. RCU serves fresher app updates when locations change rarely, RWL when they change often, and preemption helps both.</div>

The paper also redesigns both processes around preemption. A writer that receives a fresher location abandons the write in progress and starts over with the newer one. A reader lets the newest waiting application update claim the address returned by an in-flight read, rather than serving an older packet. In our numerical evaluations, preemption reduced the average application update age by close to 15 percent under RCU and 45 percent under RWL.

The result I keep returning to is not that one primitive won. It is that the synchronization primitive belongs inside the performance model rather than underneath it. The mechanism decides which update a reader actually observes, and no amount of downstream optimization can recover information that was already stale when it was read. That said, this conclusion rested on exponential service times and other modeling conveniences. The obvious challenge was to find out whether real hardware agrees, so we built a packet forwarder that measures its own freshness. That experiment is the subject of the [second post](/blog/2026/the-router-that-measured-freshness/) in this series.

{% include series_nav.liquid part=1 position="footer" %}

Vishakha Ramani is a Research Staff Member at IBM Research. She works on performance modeling and analysis of large-scale computing systems, most recently for large language model inference. She holds a PhD from Rutgers University, where she studied the timeliness of information in computing systems with Prof. Roy Yates. [Google Scholar](https://scholar.google.com/citations?user=eJg7gqwAAAAJ) · [LinkedIn](https://www.linkedin.com/in/vishakha-ramani/)
