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

With Asser N. Tantawi, I developed a tractable queueing model of this behavior. Three time-valued parameters describe a (model, GPU) pair. Mean-value analysis gives closed-form mean ITL and prefill latency, and a state-dependent birth-death Markov chain over batch size gives mean TTFT, with chunked prefill as the general case. Against vLLM on an H100 GPU with Llama-3.1-8B and Qwen2.5-14B, across 224 measurement points driven by GuideLLM, mean ITL error is about 5 and 8 percent and mean TTFT error 14 and 16 percent under light to moderate load. The parameters can be fitted online from observed latencies, so one analytic model covers heterogeneous models, GPUs, and traffic mixes without per-deployment retraining. Built into an autoscaling controller, it tracked a fourfold load ramp on an OpenShift H100 cluster while missing the latency target in only 7 of 127 control cycles.

[Paper (arXiv:2609.20957)](https://arxiv.org/abs/2609.20957) · [Blog post]({% post_url 2026-07-18-an-llm-server-in-three-numbers %}) · [Analyzer code](https://github.com/llm-d/llm-d-workload-variant-autoscaler/tree/main/internal/engines/analyzers/queueingmodel)

### Analysis, simulation, and agentic search

I also pair analytical models with the AI-Driven Research for Systems (ADRS) methodology of [Liu et al.](https://arxiv.org/abs/2510.06189) An agentic search loop proposes scheduling and autoscaling algorithms, a high-fidelity simulator evaluates them, and my models supply provable throughput and latency guarantees for what the search finds. The team's open-source pieces are [Nous](https://github.com/AI-native-Systems-Research/agentic-strategy-evolution), a hypothesis-driven experimentation framework, and [BLIS](https://github.com/inference-sim/inference-sim), the simulator Nous uses to evaluate candidates.

## PhD research

I completed my PhD at Rutgers University in 2024, advised by [Professor Roy D. Yates](https://www.winlab.rutgers.edu/~ryates/). My dissertation, [_Storing, Retrieving, and Processing Updates: A Timeliness Perspective_](/assets/pdf/Thesis_VR.pdf), studies the Age of Information (AoI): the time elapsed since the newest available update was generated at its source. Applications such as autonomous driving and remote telesurgery need information that is fresh where decisions are made, not just low latency. A car in city traffic moves about a centimeter every millisecond, so a position update a few milliseconds late describes a world that no longer exists.

Most AoI work follows updates through communication channels. My thesis follows them through shared memory, where a writer publishes time-stamped updates and a reader samples them for a client's downstream computation. The asynchronous interaction between the two raises three problems.

### Optimizing memory access

When should a reader sample shared memory? With a fixed cost per read in discrete time, I formulate a Markov decision problem and prove the optimal policy is stationary, deterministic, and threshold-type, with the threshold and average cost in closed form. When the reader cannot see the age of the update in memory, heuristics approach the known-state lower bound in realistic regimes. In continuous time, with the client as a decision process with random computation time, the main result is that _lazy reading is timely_: idling for a tuned interval before the next read lowers average age at the monitor.

Papers: [ISIT 2024](/publications/#ramani2024memory) · [WiOpt 2023](/publications/#ramani2023multisource)

### Synchronization primitives and freshness

In a packet forwarder, a writer records each mobile user's current address in a Forwarding Information Base, and the forwarder reads it to address application updates. A misaddressed update is lost, so the freshness of location updates sets the freshness of application updates. Using a Stochastic Hybrid System framework, I compare the lock-based Readers-Writer Lock (RWL) with the lock-free Read-Copy-Update (RCU). RWL delivers fresher updates at high location-update rates, and RCU at low rates. A separate result shows that with finite read time and a finite read-request rate, the number of live RCU copies stays bounded, answering the concern that lock-free synchronization can grow memory without limit.

Papers: [INFOCOM 2023](/publications/#ramani2023locks) · [INFOCOM Workshops 2024](/publications/#ramani2024rcu)

### Timely and energy-efficient multi-step processing

Some outputs need several sequential computation stages. They can run pipelined, with one processor per stage, or in parallel, with each processor running the full stack. Both waste compute: pipelines preempt or idle, and parallel workers finish updates that fresher ones have already overtaken. I formulate the age-power trade-off, find the configuration that minimizes age under a fixed power budget, and characterize the optimal service-rate allocation across stages. Synchronous sequential execution generally beats its asynchronous variant, and parallel processing tends to beat pipelining on AoI.

Paper: [Asilomar 2024](/publications/#ramani2024multistep)

See [publications](/publications/) for the full list.
