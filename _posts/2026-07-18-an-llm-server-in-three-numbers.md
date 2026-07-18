---
layout: post
title: "An LLM server in three numbers"
date: 2026-07-18 09:00
categories: research
tags: llm-serving queueing performance-modeling autoscaling
thumbnail: assets/img/blog/thumb-three-numbers.svg
description: "A note on recent work with Asser Tantawi. A queueing model of LLM inference with three hardware parameters, accurate enough to drive an autoscaler and simple enough to tune itself."
related_posts: false
---

Every operator of an LLM inference service faces the same pair of questions. If traffic doubles in the next ten minutes, how many replicas do I need to keep the time to first token under my target? And can I answer that before the queue has already formed? Benchmarking answers the first question one configuration at a time, expensively. A model answers it for configurations nobody has run yet, but only if the model is faithful to how inference servers actually behave.

In a manuscript written with Asser Tantawi, now under review at MASCOTS 2026, we built that model. The claim that makes it useful is economy. An LLM server, for our purposes, is characterized by three parameters, each with units of time and each with a physical meaning. The first is the baseline overhead of one batched iteration, the kernel launches and synchronization and weight loading that happen regardless of what is in the batch. The second is the compute time per token in a forward pass, set by the accelerator's arithmetic throughput. The third is the memory access time per token of KV cache, set by its memory bandwidth. Everything the paper predicts is built from these three numbers, the workload's token lengths, and the arrival rate.

<figure class="blog-fig">
  {% include blog/figs/m1-params.svg %}
  <figcaption>The anatomy of one batched iteration. A fixed overhead &#945;, then per-token compute and KV-cache work from every request sharing the batch, which is why iteration time is linear in the number of active requests.</figcaption>
</figure>

The modeling difficulty is that a serving engine like vLLM does not process requests one at a time. It runs continuous batching, where on every iteration boundary a finishing request departs and a waiting one is admitted, so a single forward pass mixes prefill chunks of one request with decode steps of many others. Our way through is a work-centric view. Averaged over its lifetime in the server, a request is equally likely to be found in any of its processing stages, so each active request contributes a calculable average amount of work per iteration. Iteration time then grows linearly in the number of active requests, with slope given by that per-request work and intercept given by the baseline overhead. That linearity is not an assumption of convenience. It shows up plainly in measurements, ours and others'.

On top of the work model sits a birth-death Markov chain over the number of requests in the system, with the batch size capped and the arithmetic tracking how the token budget forces long prompts to be split into chunks. Working through the chain yields the two latencies users actually experience, the time to first token and the gap between subsequent tokens, as functions of load. The same arithmetic yields the stability boundary, the arrival rate beyond which the queue grows without bound.

<figure class="blog-fig">
  {% include blog/figs/m1-chain.svg %}
  <figcaption>The birth-death chain over the number of requests in the system. Arrivals push the state up at rate &#955;, departures pull it down faster as the batch grows, and the cap at B is where queueing begins.</figcaption>
</figure>

A model this compressed has to earn trust in two ways. The first is against data. On a vLLM server with an H100 GPU, across a grid of input and output lengths from 64 to 4096 tokens and a range of arrival rates, the model's inter-token latency errors are about 5 percent for Llama-3.1-8B and 8 percent for Qwen2.5-14B, with time-to-first-token errors of 14 and 16 percent. The second is against physics. The fitted compute parameter puts the forward pass at roughly 80 percent of the H100's peak arithmetic throughput, and the fitted memory parameter puts the attention kernel at about 71 percent of peak memory bandwidth. Between the two models, the fitted compute cost scales almost exactly with parameter count. The three numbers are not just degrees of freedom that happen to fit. They come out where physically meaningful quantities should, which is a reason to believe they mean what they claim.

<figure class="blog-fig">
  {% include blog/figs/m1-fit.svg %}
  <figcaption>An illustrative version of the validation scatter. Predicted latency tracks measured latency along the diagonal across two orders of magnitude, with the largest deviations at the heaviest Qwen2.5-14B operating points.</figcaption>
</figure>

The part of this work I am most attached to is that the model tunes itself. Nobody wants to rerun a calibration suite for every model and accelerator pair, and operating conditions drift as batch composition and cache pressure change. So the parameters are estimated from the latencies the service is already observing, first by an initial fit over a handful of observations, then refreshed continuously over a sliding window at every control cycle. A model that maintains its own calibration can live inside a controller indefinitely.

And that is where we put it. We embedded the model and its tuner in an autoscaling control loop and ran it against a real vLLM deployment of Llama-3.1-8B on H100 GPUs in an OpenShift cluster, with a 50 millisecond target on time to first token. Under a trapezoidal load ramp from 120 to 480 requests per minute, the controller scaled from one replica to a peak of four, settled at three under sustained peak, and scaled back symmetrically as load fell. The visible latency spikes during scale-up come from the roughly 90 seconds a new pod needs to become ready, a hardware and orchestration effect the model deliberately does not claim to predict. What the model does predict, the steady-state operating point, tracked observed latency within a few milliseconds through the baseline phases.

<figure class="blog-fig">
  {% include blog/figs/m1-trace.svg %}
  <figcaption>An illustrative version of the autoscaling trace. Observed time to first token stays near the 50 ms target except during pod startup, while the replica count follows the trapezoidal load.</figcaption>
</figure>

<div class="key-result">Three time parameters, one Markov chain, and a self-refreshing fit are enough to predict serving latency within a few percent and to hold a 50 ms target on real GPUs.</div>

This work now ships as the [queueing model analyzer and tuner](https://github.com/llm-d/llm-d-workload-variant-autoscaler/tree/main/internal/engines/analyzers/queueingmodel) inside the Workload Variant Autoscaler, the component of the open source [llm-d](https://github.com/llm-d/llm-d) project that scales inference deployments against their service level objectives. The larger argument, the one that runs through everything I work on, is that serving AI needs models with structure, not just measurements with trend lines. This paper is that argument in its smallest complete form.

Vishakha Ramani is a Research Staff Member at IBM Research. She works on performance modeling and analysis of large-scale computing systems, most recently for large language model inference. She holds a PhD from Rutgers University, where she studied the timeliness of information in computing systems with Prof. Roy Yates. [Google Scholar](https://scholar.google.com/citations?user=eJg7gqwAAAAJ) · [LinkedIn](https://www.linkedin.com/in/vishakha-ramani/)
