<h1 align="center">Project AROHA</h1>

<p align="center">
  <strong>Integrated Polar Expedition Logistics & Asset Management System</strong><br>
  <em>Smart India Hackathon 2026 Submission | Problem Statement: SIH26062 (MoES)</em><br>
  <strong>Team Null Hypothesis</strong>
</p>

---

## The Mission
AROHA is a three-tier, offline-first logistics platform designed for India's Antarctic research bases (Maitri and Bharati). Polar expeditions face zero connectivity, extreme weather, and strict transport payload limits. AROHA replaces manual guesswork with a deterministic operations-research pipeline, ensuring survival through demand-aware forecasting, multi-factor risk scoring, and risk-reduction cargo optimization.

## Core Mathematical Pipeline
Our system features three integrated C++ modules operating natively on-station:

*   **Demand Forecasting:** Classifies demand patterns and applies Simple Exponential Smoothing (SES) for stable items or SBA/Croston methods for intermittent demand[cite: 1]. It also adjusts for planned expedition loads.
*   **Multi-Factor Criticality Scoring:** Replaces standard "days-of-supply" with a 5-factor normalized risk score combining item essentiality, urgency, lead-time risk, expedition impact, and forecast uncertainty.
*   **Cargo Optimization (Bounded Knapsack):** Maximizes operational risk reduction while strictly adhering to physical payload constraints[cite: 1]. It uses dynamic programming to select optimal shipment quantities.

## Three-Tier Architecture
AROHA is built to survive network isolation, seamlessly syncing when satellite windows open.

1.  **Facility Tier (Station):** A cross-platform **Flutter** frontend (desktop/mobile) communicating via local LAN to a highly efficient **C++ (Drogon)** backend backed by **SQLite**. Operates 100% offline.
2.  **Sync Tier (SATCOM):** Handles resumable, batched delta sync payloads with a dedicated low-bandwidth emergency burst channel to bypass standard queues.
3.  **Remote Tier (Mainland/NCPOR):** A central **Java (Spring Boot)** backend with a **MySQL** database aggregating data across all stations. A **React** dashboard serves command-center admins for cross-station planning.

## Tech Stack
| Layer | Technology |
| :--- | :--- |
| **Facility Mobile/Desktop App** | Flutter |
| **Facility Local DB** | SQLite |
| **Facility Backend & C++ Engines** | C++ (Drogon) for API, Forecasting, and Knapsack DP |
| **Sync Protocol** | REST/HTTPS, resumable delta sync |
| **Remote Backend** | Spring Boot (Java) |
| **Central DB** | MySQL |
