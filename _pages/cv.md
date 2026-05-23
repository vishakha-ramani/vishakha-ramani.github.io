---
layout: page
permalink: /cv/
title: cv
nav: true
nav_order: 4
cv_pdf: /assets/pdf/cv_academic.pdf
---

<!-- A longer, narrative-style CV with detailed project descriptions and citation counts is also available at [cv.pdf](/assets/pdf/cv.pdf). -->

## Research Interests

Performance modeling and analysis of large-scale systems, queueing theory and stochastic optimization, large language model inference serving, Age of Information, and cloud-native infrastructure for AI workloads.

## Education

**Rutgers University, New Brunswick.** Ph.D., Electrical and Computer Engineering, 2020 to 2024. Dissertation: [*Storing, Retrieving, and Processing Updates: A Timeliness Perspective*](/assets/pdf/Thesis_VR.pdf). Advisor: [Professor Roy D. Yates](https://www.winlab.rutgers.edu/~ryates/) (WINLAB).

**Rutgers University.** M.S., Electrical and Computer Engineering, 2017 to 2019. Thesis: *I-Mac: An ICN Based Radio Access Network Architecture*. Advisor: Professor Dipankar Raychaudhuri.

**Rajiv Gandhi Prodyogiki Vishwavidyalaya.** B.Tech. and M.Tech. (dual degree), Electronics and Communication Engineering, 2011 to 2016.

## Professional Experience

**Research Staff Member**, IBM Thomas J. Watson Research Center, Yorktown Heights, NY. October 2024 to present.

- Co-architect of the Workload Variant Autoscaler (WVA) for [llm-d](https://github.com/llm-d), an open-source Kubernetes-native LLM inference system ([WVA repo](https://github.com/llm-d/llm-d-workload-variant-autoscaler), [llm-d architecture docs](https://llm-d.ai/docs/architecture)). Produced the first end-to-end system design and led the autoscaling effort with the broader llm-d community.
- Designed and implemented the queueing model analyzer at the analytical core of WVA. The analyzer is a hardware-aware performance model of LLM inference that predicts time-to-first-token and inter-token latency, and computes the maximum sustainable request rate per replica under SLO constraints. Model parameters are learned online via a Kalman filter, removing the need for offline profiling.
- Co-authored the WVA system paper, A. Malvankar et al., *WVA: A Global Optimization Control Plane for llm-d*, IEEE CLOUD 2026 (to appear).
- Contributed analysis to T. Abdelzaher et al., *The Bottlenecks of AI*, Real-Time Systems, vol. 61, 2025, framing open problems in scaling inference serving under latency SLOs, GPU memory management, and orchestration of heterogeneous accelerators.
- Developing an analytical framework for prefill-decode disaggregation, deriving a dynamic scheduling threshold via Lyapunov optimization on a tandem queueing model with provable throughput and latency guarantees (manuscript in preparation).
- Applying the AI-Driven Research for Systems methodology of [Liu et al.](https://arxiv.org/abs/2510.06189) to scheduling and autoscaling problems in llm-d, contributing analytical performance models that supply provable guarantees for algorithms discovered by the agentic search loop. Related open-source team artifacts include [BLIS](https://github.com/inference-sim/inference-sim), the simulation substrate, and [Agentic Strategy Evolution](https://github.com/AI-native-Systems-Research/agentic-strategy-evolution), the search loop.

**Graduate Research Assistant**, Rutgers University, New Brunswick. September 2018 to October 2024.

*Ph.D. research, Age of Information in computing systems.*

- *AoI in shared memory and synchronization.* Analyzed the impact of synchronization primitive choice (lock-based reader-writer locks vs. lock-free Read-Copy-Update) on information freshness in shared-memory status-updating systems. Showed that the optimal choice depends on the update rate regime, with lock-based primitives favoring high-rate workloads and lock-free favoring low-rate workloads. Characterized age-memory trade-offs in RCU systems (INFOCOM 2023, INFOCOM 2024 Workshop).
- *Optimal memory access policies.* Formulated an optimal memory sampling problem in status-updating systems and proved the optimal policy is a stationary, deterministic threshold-type policy. Derived closed-form AoI expressions (ISIT 2024).
- *Multi-source and multi-step update processing.* Developed analytical models for AoI in publish-subscribe systems with multiple sources, showing a lazy computation policy can reduce average AoI at the monitor (WiOpt 2023). Extended to multi-step pipelines, identifying wasted computation when processing effort does not reduce age, and optimized service rates under power constraints (Asilomar 2024).
- *Experimental timeliness in mobile networks.* DPDK-based testbed studies of timely packet routing, demonstrating AoI sensitivity to offered load and concurrency constructs in real deployments (INFOCOM 2023 Workshop).

*M.S. research, ICN-based wireless access networks.*

- Designed an Information-Centric Networking based RAN protocol for LTE enabling efficient wireless multicast via a cross-layer architecture integrating ICN identifiers with LTE RAN. Verified with NS-3 and SUMO simulations.
- Designed a scalable ICN-based MAC scheduling algorithm using convex optimization for joint resource allocation across unicast and multicast user groups.

**Research Intern**, IBM Thomas J. Watson Research Center. May to August 2023.

- Performance analysis of the Multi-Cluster App Dispatcher using Kubernetes Without Kubelet to identify scheduling bottlenecks in cloud-native foundation model workloads.
- Presented findings at KubeCon and CloudNativeCon North America 2023.

**Research Intern**, IBM Thomas J. Watson Research Center. May to August 2022.

- Built a middleware stack for distributed training of foundation models on OpenShift as part of Project Codeflare.
- Contributed open-source code to TorchX.
- Benchmarked multi-tenant cluster schedulers under concurrent foundation model training workloads.

**Assistant System Engineer**, Tata Consultancy Services, Mumbai, India. February to July 2017.

- Business intelligence and performance management. Developed BI solutions using IBM Cognos.

## Professional Service

**Program Committee Member**, AAAI/ACM Conference on AI, Ethics, and Society (AIES) 2026, Malmö, Sweden.

**Reviewer for** IEEE Journal on Selected Areas in Communications, IEEE Transactions on Wireless Communications, IEEE Transactions on Communications, IEEE International Symposium on Information Theory, IEEE Internet of Things Journal, Ad Hoc Networks (Elsevier), and BalkanCom.

## Invention Disclosures

A. Malvankar, A. Tantawi, **V. Ramani**, T. Eilam, M. Abdi. *System and Method for Efficient SLO-Aware Autoscaling of AI Inference Workloads.* IBM Invention Disclosure P202503087, 2025.

## Honors and Awards

- CNCF Travel Grant, KubeCon and CloudNativeCon North America 2023.
- Graduate Research Assistantship, Rutgers University (WINLAB), 2018 to 2024.
- Teaching Assistantship, Rutgers University, ECE Department.

## Technical Skills

**Methods.** Queueing theory, Lyapunov optimization, stochastic processes, convex optimization, Age of Information analysis.

**Systems.** Kubernetes, OpenShift, DPDK, NS-3, SUMO.

**Languages.** Python, Go, C, C++, MATLAB, SQL, Verilog.
