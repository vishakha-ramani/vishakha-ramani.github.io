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

I completed my PhD at Rutgers University in 2024, advised by Professor Roy D. Yates, with a dissertation titled *Storing, Retrieving, and Processing Updates: A Timeliness Perspective*. My research studied status updating systems, where a monitor or downstream consumer cares about the freshness of information rather than the throughput of bytes. The Age of Information (AoI) metric makes that intuition precise. It captures the time elapsed since the most recent successfully delivered update was generated at the source, and it has reshaped how queueing theorists think about latency for sensing, control, and learning workloads.

The thesis examined three challenges that arise when a system stores, retrieves, and processes such updates. The first part developed optimal reading policies for a shared cache that holds the latest versions of many sources. A reader who pulls too aggressively wastes capacity, and one who pulls too rarely consumes stale data. I derived structural results that characterize when a threshold-based reading policy minimizes long-run average AoI under realistic constraints. The second part turned to the synchronization primitives that protect those caches. Lock-based and lock-less designs trade off freshness against contention in different ways, and the right choice depends on the read-write mix and on how the application weighs staleness. The third part studied multi-step processing pipelines, where freshness at the output of stage k depends on every choice made at stages 1 through k-1, and showed how Lyapunov drift-plus-penalty optimization yields stable scheduling policies that respect end-to-end freshness targets.

## AI inference serving at scale

At IBM I am the co-architect of the Workload Variant Autoscaler (WVA) for the open-source [llm-d](https://github.com/llm-d) project, a horizontal autoscaler for large language model inference that reasons about prefill and decode behavior rather than treating an inference deployment as a generic web service. Two manuscripts are in preparation. One develops a queueing-theoretic foundation for serving disaggregated prefill-decode systems, and the other extends that foundation into a scheduling and autoscaling framework that holds Service Level Objectives under bursty, heterogeneous request mixes.

## Outside of research

I follow professional road cycling closely. The 2025 men's calendar gave us Tadej Pogačar finally winning Milan-San Remo after years of near-misses on the Via Roma, Wout van Aert finally winning Paris-Roubaix on a brutal day in the Arenberg, and Mathieu van der Poel reminding everyone what cobbled mastery looks like. The young French rider Paul Seixas has become the most-discussed grand tour prospect in a decade. The women's calendar has been just as gripping. Katarzyna Niewiadoma's four-second overall victory at the 2024 Tour de France Femmes over Demi Vollering is the closest grand tour finish in modern memory, men's or women's. Vollering's move from SD Worx-Protime to FDJ-Suez reshuffled the team dynamics at the top of the peloton, and Lotte Kopecky has continued to dominate the spring classics.

Away from the bike, I play piano on occasion.
