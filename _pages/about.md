---
layout: about
title: about
permalink: /
subtitle: Research Staff Member, IBM T. J. Watson Research Center. Performance modeling and analysis of computing systems.

profile:
  align: right
  image: prof_pic.jpg
  image_circular: false
  more_info:

selected_papers: false
social: true

announcements:
  enabled: false
  scrollable: true
  limit: 5

latest_posts:
  enabled: false
  scrollable: true
  limit: 3
---

Hi. I am Vishakha, a Research Staff Member at IBM T. J. Watson Research Center in Yorktown Heights, New York. I work on the performance modeling and analysis of computing systems. My current focus is the scheduling and autoscaling of large language model inference serving at production scale.

## My PhD research

I completed my PhD at Rutgers University in 2024, advised by [Professor Roy D. Yates](https://www.winlab.rutgers.edu/~ryates/), with a dissertation titled [*Storing, Retrieving, and Processing Updates: A Timeliness Perspective*](/assets/pdf/Thesis_VR.pdf). Time-critical applications such as autonomous driving, augmented and virtual reality, and remote telesurgery need more than low latency. They need information that is fresh at the point where decisions are made. A car driving through a city moves about a centimeter every millisecond, so a position update that arrives a few milliseconds late describes a world that no longer exists. The Age of Information (AoI) metric was introduced to make this intuition precise. It captures the time elapsed since the most recent update was generated at the source, and it has reshaped how queueing theorists think about timeliness for sensing, control, and learning workloads.

My thesis studied a gap in the AoI literature. Most prior work tracked updates as they flowed through communication channels, but in real systems updates also have to be *stored*, *retrieved*, and *processed*, and the way that storage and computation are organized can dominate end-to-end freshness. I focused on producer-consumer systems built on shared memory, where a writer process publishes time-stamped updates to a shared data structure and a reader process samples that memory on behalf of a client that uses the update for downstream computation. The asynchronous interaction between writers and readers introduces three coupled challenges that the dissertation works through in turn.

#### Optimizing memory access

The first part develops policies that decide when a reader should sample shared memory. In a discrete-time setting where each read carries a fixed cost, I formulate the problem as a Markov decision problem and prove that an optimal sampling policy is stationary, deterministic, and threshold-type. I derive the optimal threshold and the corresponding average cost in closed form. I then extend the analysis to the case where the reader does not observe the age of the update currently in memory and develop heuristics that approach the known-state lower bound under realistic regimes. In a continuous-time variant, where the client itself is a decision process with random computation time, the main result is that *lazy reading is timely*. Letting the reader idle for a tuned interval before the next sample reduces average age at the monitor, even though the reader has no control over how the source generates updates.

#### Synchronization primitives and freshness

The second part studies how the synchronization primitives that protect shared memory shape AoI. The setting is a packet forwarder that maintains a Forwarding Information Base. A writer process records the current address of each mobile user as a location update. The forwarder consumes application updates arriving from a server and reads the FIB to address them to the user. A misaddressed application update is lost in transit, so the freshness of the location update directly determines the freshness of the application update at the user. I analyze two widely used primitives, the lock-based Readers-Writer Lock and the lock-free Read-Copy-Update, using a Stochastic Hybrid System framework. The two age processes turn out to be coupled through the primitive, and the practical recommendation depends on operating regime. RWL serves fresher application updates at higher location-update rates, while RCU is more effective at lower rates. A separate chapter quantifies the memory footprint of RCU and shows that, with finite read time and a finite read-request rate, the number of live update copies stays bounded, addressing a long-standing concern that lock-free synchronization could lead to unbounded memory growth.

#### Timely and energy-efficient multi-step processing

The third part turns from individual reader-writer pairs to multi-step processing pipelines, where producing a usable output requires several sequential computational stages. The natural design choices are pipelined execution, in which different processors handle different stages, and parallel execution, in which independent processors each carry out the full stack. Both designs waste compute. A pipeline can preempt or idle, and a parallel deployment can finish older updates that have already been overtaken by fresher ones. I formulate the age-power trade-off, ask which configuration minimizes age under a fixed power budget, and characterize the optimal service-rate allocation across stages. The analysis shows that synchronous sequential execution generally outperforms its asynchronous variant, and that parallel processing tends to dominate pipelined processing in AoI terms.

## My work at IBM Research

Since joining IBM Research in October 2024, my focus has shifted from networking and shared-memory systems to large language model inference serving at production scale. The questions are different in surface form but recognizably the same in spirit. A modern inference deployment is a producer-consumer system in which user requests arrive at unpredictable rates, accelerators are an expensive shared resource, and end-to-end latency targets are a Service Level Objective rather than a soft preference. The challenge is to schedule and scale this system so that latency targets are held without stranding capacity.

I am the co-architect of the [Workload Variant Autoscaler](https://github.com/llm-d/llm-d-workload-variant-autoscaler) (WVA) for the open-source [llm-d](https://github.com/llm-d) project, a horizontal autoscaler for large language model inference that reasons about prefill and decode behavior rather than treating an inference deployment as a generic web service. The technical work behind WVA, and the broader scheduling and autoscaling problem in llm-d, spans three threads.

#### Modeling an inference server

A modern LLM inference server processes each request in two phases. The prefill phase runs a single forward pass over the entire prompt, builds the per-request key-value cache, and emits the first output token. The dense matrix multiplies in this pass scale with input length, so prefill is compute-bound. The decode phase then generates output tokens one at a time, with each step reading the entire KV cache from high-bandwidth memory to predict the next token. The per-step compute is small but the memory traffic grows with the cache, so decode is memory-bandwidth-bound. Modern servers run continuous batching across these phases, admitting any waiting request at the next iteration boundary, so prefilling and decoding requests sit in the same forward pass and the batch composition shifts continuously.

This phase asymmetry produces two latency metrics that matter for user experience. Time-to-First-Token (TTFT) is the elapsed time from a request's arrival until its first output token is produced, governed by queueing wait and prefill work. Inter-Token Latency (ITL) is the average time between successive output tokens during decoding, governed by per-iteration decode work and the size of the KV cache.

In a manuscript with my IBM colleague Asser N. Tantawi, I develop a tractable parameterized queueing model that captures both metrics under continuous batching. Three time-valued parameters compress the entire (model, GPU) pairing into a small state. A mean-value analysis yields a closed-form expression for mean ITL and prefill latency, while a state-dependent birth-death Markov chain over the active batch size is solved numerically for mean TTFT. The model handles chunked prefill as the general case and recovers the unchunked regime as a special case. We validate against a vLLM server on an H100 GPU running Llama-3.1-8B and Qwen2.5-14B, driven by GuideLLM across 224 measurement points, with relative error under 13.5 percent on both metrics. The three parameters are estimable online from observed latencies, so a single analytic controller can predict TTFT and ITL across heterogeneous models, GPUs, and traffic mixes without per-deployment retraining (manuscript in preparation).

#### Optimal scheduling for prefill-decode disaggregation

The phase asymmetry has prompted production systems including Splitwise, DistServe, Mooncake, NVIDIA Dynamo, and llm-d to run prefill and decode on separate GPU pools, transferring the KV cache between them over the network. The scheduler now faces a per-request decision. Route the request through a separate prefill worker plus a KV-cache transfer, or run both phases on a unified worker. Disaggregation protects ITL by removing prefill interference from the decode batch, but it inflates TTFT through prefill-queue waiting and the transfer cost. Deployed schedulers make this choice with prefix-cache-aware, queue-aware heuristics that work empirically but lack analytical foundation.

In a separate solo manuscript, I treat the disaggregated server as a tandem queue and derive the dynamic routing rule via Lyapunov drift-plus-penalty optimization. The state of the rule combines the prefill backlog, the decode population, the work ratio between the two phases, and a virtual queue that enforces a mean-TTFT Service Level Objective. Minimizing drift per slot yields a closed-form threshold that decides disaggregation per request. The policy inherits the standard drift-plus-penalty trade-off, with ITL gap relative to the best stationary policy at order 1 over V and time-average backlog at order V. Four corollaries recover deployed heuristics as special cases of the general rule, including llm-d's prefix-based decider, always-local routing, always-disaggregate routing, and stationary-randomized routing. The capacity region of always-disaggregate strictly contains that of always-local whenever the unified server is unstable but the prefill and decode pools are individually stable, which gives a precise condition under which disaggregation is not just useful but necessary (manuscript in preparation).

#### Validating analysis with simulation and agentic search

A growing thread in my work is integrating analytical performance models with the AI-Driven Research for Systems (ADRS) methodology of [Liu et al.](https://arxiv.org/abs/2510.06189) ADRS pairs an agentic search loop that proposes candidate scheduling and autoscaling algorithms with a high-fidelity simulator that evaluates them. My role is to supply analytical performance models that give provable throughput and latency guarantees for the algorithms the search loop discovers. The team's open-source artifacts in this space are [Nous](https://github.com/AI-native-Systems-Research/agentic-strategy-evolution), a hypothesis-driven experimentation framework that runs the scientific method on software systems, and [BLIS](https://github.com/inference-sim/inference-sim), the simulation substrate Nous uses to evaluate candidate algorithms. Used together, the simulator measures empirical performance, the models prove the bounds, and the search loop closes the design cycle on scheduling and autoscaling problems in llm-d.

## Outside of research

I follow professional road cycling closely, both the men's and women's calendars. The spring classics and the three grand tours are the highlights of my year, with the cobbled monuments and the high mountains drawing the most committed watching. See [/now](/now/) for the current race I am following.

Away from the bike, I play piano on occasion.
