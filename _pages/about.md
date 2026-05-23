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

I am the co-architect of the Workload Variant Autoscaler (WVA) for the open-source [llm-d](https://github.com/llm-d) project, a horizontal autoscaler for large language model inference that reasons about prefill and decode behavior rather than treating an inference deployment as a generic web service. Two manuscripts are in preparation. One develops a queueing-theoretic foundation for serving disaggregated prefill-decode systems, and the other extends that foundation into a scheduling and autoscaling framework that holds Service Level Objectives under bursty, heterogeneous request mixes.

## Outside of research

I follow professional road cycling closely. The 2026 men's spring gave us two long-awaited firsts. Tadej Pogačar finally won Milan-San Remo, holding off Tom Pidcock by half a wheel on the Via Roma after riding much of the final 30 km on a cracked frame from an earlier crash, and three weeks later Wout van Aert finally won Paris-Roubaix, outsprinting Pogačar in the velodrome on the fastest edition in the race's history. Pogačar then took Liège-Bastogne-Liège for the fourth time, with the 19-year-old French rider Paul Seixas in second, confirming his status as the most-discussed grand tour prospect in a decade. The women's spring belongs to Demi Vollering, who moved from SD Worx-Protime to FDJ-Suez over the winter and won Omloop, Flanders, Flèche Wallonne, and Liège-Bastogne-Liège in a single calendar. The Giro is in its final week as I write this, with Afonso Eulálio of Bahrain Victorious in the maglia rosa and Jonas Vingegaard 33 seconds back.

Away from the bike, I play piano on occasion.
