---
layout: about
title: about
permalink: /
subtitle: Research Staff Member, IBM T. J. Watson Research Center

profile:
  align: right
  image: prof_pic.jpg
  image_circular: false
  more_info:

selected_papers: true
social: true

announcements:
  enabled: false

latest_posts:
  enabled: false
---

I am a Research Staff Member at IBM T. J. Watson Research Center in Yorktown Heights, New York. I work on performance modeling and analysis of computing systems. My current focus is scheduling and autoscaling large language model inference at production scale.

## Research

**Queueing models of LLM inference.** Three parameters per model–GPU pair predict time to first token and inter-token latency closely enough to drive an autoscaler. [Paper](https://arxiv.org/abs/2609.20957) · [Blog post]({% post_url 2026-07-18-an-llm-server-in-three-numbers %})

**Autoscaling in llm-d.** I co-architected the Workload Variant Autoscaler, which sizes LLM inference deployments against latency targets. [Code](https://github.com/llm-d/llm-d-workload-variant-autoscaler)

**Age of Information.** My PhD at Rutgers (2024), with Roy Yates, on keeping data fresh as it is stored, retrieved, and processed. [Thesis](/assets/pdf/Thesis_VR.pdf)

[More on my research →](/research/)

## News

- **Sep 2026.** Preprint with Asser Tantawi on arXiv: [_An Approximate Queueing Model of LLM Inference Serving for SLO-Driven Autoscaling_](https://arxiv.org/abs/2609.20957).
- **2026.** WVA paper, _A Global Optimization Control Plane for llm-d_, to appear at IEEE CLOUD 2026.

Outside research, I follow professional road cycling closely ([what I'm watching now](/now/)) and play piano on occasion.
