# OmniCommerce — Master Roadmap & Learning Log

> 🇻🇳 Vietnamese version: [roadmap.vi.md](roadmap.vi.md)

This file is the single source of truth for **what to do each day**, **what "done" means**, and **what was learned**.

- The schedule is a guide, not a deadline. A "day" is one learning unit and may take more than one calendar day.
- Tick tasks only after they have actually been run and verified.
- Detailed tasks are written for the current milestone. Later milestones list a focus and deliverable per day and are refined when that milestone starts.

**Status legend:** ⬜ Not started · 🟨 In progress · ✅ Done · ⏸ Deferred

---

## Progress Overview

| # | Milestone | Weeks | Status | Started | Finished |
|---|---|---|---|---|---|
| 1 | Data Engineering Foundations | 1–2 | 🟨 | 2026-10-08 | |
| 2 | Batch Ingestion & CDC | 3–4 | ⬜ | | |
| 3 | Streaming Architecture | 5–6 | ⬜ | | |
| 4 | Data Lakehouse | 7–8 | ⬜ | | |
| 5 | Batch & Stream Processing | 9–10 | ⬜ | | |
| 6 | Data Modeling & Serving | 11–12 | ⬜ | | |
| 7 | Orchestration & Governance | 13–14 | ⬜ | | |
| 8 | Production Readiness | 15–16 | ⬜ | | |

**Current focus:** M1 · Day 1 — Project setup, Docker Compose, data architecture.

---

## Milestone 1 — Data Engineering Foundations

**Goal:** Two independently owned operational databases, a reproducible local environment, and synthetic data sources (batch, continuous, API, files) that later milestones will ingest.

**Exit criteria**

- [ ] From a fresh clone, `cp .env.example .env && make up` starts healthy PostgreSQL and MySQL.
- [ ] Schemas include primary keys, foreign keys, constraints, and justified indexes.
- [ ] The generator loads ~100k records reproducibly (same seed produces the same data).
- [ ] The continuous workload runs at a configurable rate and survives a database restart.
- [ ] The mock API and CSV/JSON sources serve data with documented contracts.
- [ ] The validation suite passes, and broken data is detected.
- [ ] Benchmark numbers come from real runs, with hardware noted.
- [ ] ADR-001 is written, and every day's lesson is documented.

### Day 1 — Project Setup, Docker Compose, Data Architecture · 🟨

**Learning goals:** images vs containers · named volumes vs bind mounts · port publishing and `127.0.0.1` binding · healthchecks · `.env` interpolation (`$` vs `$$`) · how the database entrypoint runs init scripts · OLTP vs OLAP · why database ownership matters.

**Tasks**

- [x] Repository created and pushed to GitHub
- [x] README draft
- [x] `infrastructure/docker/compose.yml` for PostgreSQL 16 and MySQL 8.4 (`docker compose config` passes)
- [x] `.env.example` added and `.env` ignored by git
- [x] Replace the `001_init.sql` directories (created by Docker) with real SQL files
- [x] Reset volumes (`docker compose down -v`) and re-initialize cleanly
- [x] Both containers report `healthy` in `docker compose ps`
- [x] Connect from inside the container (`psql`, `mysql`) and from the host (MySQL from host: port check only, no client installed)
- [x] Persistence test: write a row → `down` → `up` → the row still exists
- [x] Rename `MAKEFILE` → `Makefile`; add targets `up`, `down`, `ps`, `logs`, `psql`, `mysql`
- [ ] Add `LICENSE` (decision pending: MIT vs Apache-2.0)
- [x] Conceptual data model and ERD (Mermaid) in `docs/architecture/data-model.md`
- [x] Database ownership table (which service owns which entity)
- [x] ADR-0001: Two independent operational databases (`docs/decisions/`)
- [x] Day 1 lesson in `docs/milestones/01-foundations/` (EN + VI)
- [ ] (You) Work through the guide yourself; Break & Fix exercises A–C
- [ ] (You) Review the ERD and ADR-0001; challenge anything you disagree with
- [ ] (You) Write "What I learned" in the learning log
- [ ] Commit and push

**Definition of Done:** a clean `down -v` → `up` cycle produces two healthy, initialized databases; the persistence test passes; the ERD and ADR-001 are committed.

### Day 2 — Database Schema, Constraints, Indexes · ⬜

**Learning goals:** keys (surrogate vs natural, `BIGINT IDENTITY` vs UUID) · `NOT NULL`, `UNIQUE`, `CHECK`, foreign keys · data types for money and time (`NUMERIC`, `timestamptz`, UTC) · normalization · B-tree indexes · `EXPLAIN ANALYZE` · ACID and transaction boundaries.

- [ ] PostgreSQL DDL: `customers`, `orders`, `order_items`, `payments`
- [ ] MySQL DDL: `categories`, `products`, `inventory`
- [ ] `created_at` / `updated_at` conventions (needed later for incremental ingestion)
- [ ] Indexes for the main query patterns; `EXPLAIN` before/after each one
- [ ] Constraint violation tests (insert bad rows and confirm they are rejected)
- [ ] Note: no foreign key can span two databases; document how `order_items.product_id` stays consistent

**Definition of Done:** schemas apply from init scripts on a clean volume; every constraint has a failing-insert test; each index has a justification and an `EXPLAIN` result.

### Day 3 — Synthetic Data Generator · ⬜

**Learning goals:** deterministic seeds · realistic distributions (skew, Pareto customers) · referential integrity across two databases · bulk loading (`COPY` / batched inserts vs row-by-row).

- [ ] `apps/data-generator/` Python project (config file, type hints, structured logging)
- [ ] Generate categories, products, inventory, customers, orders, order items, payments
- [ ] Same seed produces identical output (test)
- [ ] Load ~100k records; measure rows/second for row-by-row vs bulk loading
- [ ] Edge cases: nulls in optional fields, very large orders, duplicate-looking customers

**Definition of Done:** `make seed` loads a reproducible dataset; load throughput is recorded.

### Day 4 — Continuous Transactional Workload · ⬜

**Learning goals:** order lifecycle state machine · update/delete traffic (matters for CDC) · rate control · graceful shutdown · retries with backoff · idempotency.

- [ ] Order lifecycle: `created → paid → shipped → delivered`, plus `cancelled` and `payment_failed`
- [ ] Customer updates, product price updates and deletes, inventory changes
- [ ] Configurable events/second (10, 100, 500)
- [ ] Retries with backoff on connection loss; no infinite retry loops
- [ ] Ctrl+C stops cleanly without leaving half-written orders

**Definition of Done:** the workload runs for 10+ minutes at the target rate; restarting the database during the run does not crash it or corrupt data.

### Day 5 — Mock REST API & File Sources · ⬜

**Learning goals:** API as a data source · pagination · rate limits · failure injection · file formats (CSV vs JSON) and their pitfalls.

- [ ] `apps/mock-api/` (FastAPI): marketing campaigns and daily campaign metrics
- [ ] Pagination, configurable latency, and error injection (HTTP 429/500)
- [ ] Historical CSV/JSON exports in `data/samples/` (small, committed)
- [ ] Documented data contract for each endpoint and file

**Definition of Done:** the API runs via Compose; the files load without manual fixes; the contracts are documented.

### Day 6 — Data Validation & Quality · ⬜

**Learning goals:** quality dimensions (completeness, uniqueness, validity, consistency, accuracy, freshness) · cross-database reconciliation.

- [ ] SQL checks: orphan rows, duplicates, negative amounts, invalid status transitions
- [ ] Cross-database check: every ordered `product_id` exists in MySQL
- [ ] pytest suite that runs the checks
- [ ] Inject bad data on purpose and confirm the checks catch it

**Definition of Done:** `make test` passes on clean data and fails with clear messages on corrupted data.

### Day 7 — End-to-End Demo, Benchmark, Documentation · ⬜

- [ ] `make demo`: up → seed → workload → validate
- [ ] Benchmark: load throughput, workload throughput, database size — measured, not estimated
- [ ] Milestone 1 documentation and README status update

**Definition of Done:** a new person can follow the docs from a fresh clone to a working demo.

### Day 8 — Deep Dive: Transactions, Isolation, Locking · ⬜

- [ ] Isolation levels demo (read committed vs repeatable read vs serializable)
- [ ] MVCC in PostgreSQL vs InnoDB; lost updates on inventory; `SELECT … FOR UPDATE`
- [ ] Reproduce and explain a deadlock

### Day 9 — Generator Reliability · ⬜

- [ ] Resume after a crash without duplicating data
- [ ] Failure drills: kill the database mid-batch, network pause (`docker pause`)
- [ ] Structured logs and basic counters (events sent, failed, retried)

### Day 10 — CDC Preparation & M1 Retrospective · ⬜

- [ ] PostgreSQL: `wal_level=logical`, replication slots, `REPLICA IDENTITY`
- [ ] MySQL: binary log (ROW format), GTID, `binlog_row_image`
- [ ] Dedicated least-privilege CDC users
- [ ] Review the M1 exit criteria; write the retrospective

---

## Milestone 2 — Batch Ingestion & CDC

**Goal:** Move data out of the operational databases with batch (incremental) and log-based CDC, and understand the trade-offs.

**Exit criteria:** incremental batch and CDC both capture inserts, updates, and deletes; ingestion can be re-run without duplicates; failure drills are documented.

| Day | Focus & key concepts | Deliverable | Status |
|---|---|---|---|
| 1 | Ingestion patterns: full vs incremental, cursors, watermarks, idempotency | Ingestion concepts doc; landing-zone decision (ADR) | ⬜ |
| 2 | Hand-written incremental ingestion (Python, `updated_at` cursor) | Script plus a demo of what it misses (hard deletes, late updates) | ⬜ |
| 3 | Airbyte setup (resource-heavy; check requirements first); full refresh sync | First working sync | ⬜ |
| 4 | Airbyte incremental + dedup modes; schema change test | Incremental sync report | ⬜ |
| 5 | CDC theory: WAL, binlog, query-based vs log-based, snapshots | CDC concepts doc | ⬜ |
| 6 | Minimal Kafka + Kafka Connect + Debezium PostgreSQL connector | Change events in a topic | ⬜ |
| 7 | Debezium MySQL connector; event envelope (`before`/`after`/`op`/`source`) | Both sources streaming | ⬜ |
| 8 | Connector offsets, restarts, replication slot growth while the connector is down | Failure drill write-up | ⬜ |
| 9 | Schema evolution, deletes and tombstones, deduplication | Schema change experiment | ⬜ |
| 10 | Reliability review; ADR: Airbyte vs Debezium roles; retrospective | ADR + M2 docs | ⬜ |

---

## Milestone 3 — Streaming Architecture

**Goal:** Understand Kafka deeply and build reliable event pipelines for orders, inventory, and customer activity.

**Exit criteria:** producers and consumers with known delivery guarantees; schemas enforced; replay and recovery demonstrated; lag measured under load.

| Day | Focus & key concepts | Deliverable | Status |
|---|---|---|---|
| 1 | Brokers, topics, partitions, offsets, KRaft | Topic design doc | ⬜ |
| 2 | Producers: keys and ordering, partitioner, `acks`, idempotent producer, batching | Order event producer | ⬜ |
| 3 | Consumers, consumer groups, rebalancing, offset commit strategies | Consumer service | ⬜ |
| 4 | Delivery semantics: at-most / at-least / exactly-once; transactions | Experiments showing each one | ⬜ |
| 5 | Schema Registry, Avro/Protobuf, compatibility modes | Registered schemas plus a breaking-change test | ⬜ |
| 6 | Clickstream and app events; Fluent Bit for application logs | Activity and log topics | ⬜ |
| 7 | Retries, poison messages, dead-letter topics | DLQ flow | ⬜ |
| 8 | Retention, log compaction, replay and recovery | Replay drill | ⬜ |
| 9 | Multi-broker replication, ISR, `min.insync.replicas`, broker failure | Broker-kill experiment | ⬜ |
| 10 | Consumer lag, backpressure, throughput at 10/100/500/1000 events/s; retrospective | Benchmark results | ⬜ |

---

## Milestone 4 — Data Lakehouse

**Goal:** Land data in open formats on object storage and build the Bronze / Silver / Gold layers on Iceberg.

**Exit criteria:** Bronze, Silver, and Gold Iceberg tables on MinIO; CDC changes merged correctly into Silver; time travel, schema evolution, and compaction demonstrated.

| Day | Focus & key concepts | Deliverable | Status |
|---|---|---|---|
| 1 | Object storage, S3 API, MinIO | MinIO in Compose (profile) | ⬜ |
| 2 | Row vs columnar, Parquet internals, compression | File format size and speed experiment | ⬜ |
| 3 | Table formats, Iceberg metadata/manifests/snapshots, catalog options | ADR: Iceberg + catalog choice | ⬜ |
| 4 | Bronze: raw CDC/events into Iceberg (choose write engine) | Bronze tables | ⬜ |
| 5 | Partitioning, hidden partitioning, partition evolution | Partitioning experiment | ⬜ |
| 6 | Silver: clean, deduplicate, apply CDC with `MERGE INTO` | Silver tables | ⬜ |
| 7 | Gold: business-ready datasets | Gold tables | ⬜ |
| 8 | Time travel, rollback, schema evolution | Demo notebook/script | ⬜ |
| 9 | Small-file problem, compaction, snapshot expiration | Before/after metrics | ⬜ |
| 10 | Storage benchmark; retrospective | M4 docs | ⬜ |

---

## Milestone 5 — Batch & Stream Processing

**Goal:** Spark for distributed batch processing, Flink for stateful real-time processing.

**Exit criteria:** a Spark pipeline from Bronze to Gold with tuning evidence; Flink jobs with event-time windows and state that recover from failure.

| Day | Focus & key concepts | Deliverable | Status |
|---|---|---|---|
| 1 | Spark architecture: driver, executors, cluster manager | Local Spark cluster | ⬜ |
| 2 | DataFrames, lazy evaluation, jobs/stages/tasks, Spark UI | Annotated Spark UI walkthrough | ⬜ |
| 3 | Joins, shuffle, broadcast joins, data skew | Join experiments | ⬜ |
| 4 | Partitioning, memory, AQE, tuning | Tuning report | ⬜ |
| 5 | Production-grade Spark pipeline Bronze → Silver → Gold | Pipeline + tests | ⬜ |
| 6 | Flink architecture: JobManager, TaskManager, slots | Local Flink cluster | ⬜ |
| 7 | Event time vs processing time, watermarks, windows | Real-time revenue per minute | ⬜ |
| 8 | Keyed state, timers | Abandoned-cart detection | ⬜ |
| 9 | Checkpoints, savepoints, exactly-once sinks, failure recovery | Kill-and-recover drill | ⬜ |
| 10 | Late events; benchmarks; ADR: Spark + Flink; retrospective | M5 docs | ⬜ |

---

## Milestone 6 — Data Modeling & Serving

**Goal:** Dimensional models with dbt, served through Trino and ClickHouse, visualized in Superset.

**Exit criteria:** dbt project with tests and docs; facts, dimensions, and marts built; dashboards answer the business questions; serving trade-offs measured.

| Day | Focus & key concepts | Deliverable | Status |
|---|---|---|---|
| 1 | Dimensional modeling: grain, facts, dimensions, star schema | Model design doc | ⬜ |
| 2 | dbt setup and execution engine choice; sources and staging | ADR + staging models | ⬜ |
| 3 | `fact_orders`, `fact_order_items`, `fact_payments` | Fact models | ⬜ |
| 4 | `dim_customers` (SCD Type 2), `dim_products` | Dimension models + snapshots | ⬜ |
| 5 | Incremental models, tests, docs, lineage graph | `dbt build` passes | ⬜ |
| 6 | `mart_daily_revenue`, `mart_product_performance`, `mart_customer_behavior` | Marts | ⬜ |
| 7 | Trino: coordinator/workers, connectors, federation, `EXPLAIN` | Trino over Iceberg | ⬜ |
| 8 | ClickHouse: MergeTree, ordering keys, materialized views | Selected marts in ClickHouse | ⬜ |
| 9 | Superset dashboards | Revenue, product, funnel dashboards | ⬜ |
| 10 | Trino vs ClickHouse query benchmark; ADR; retrospective | M6 docs | ⬜ |

---

## Milestone 7 — Orchestration & Governance

**Goal:** Orchestrate the full pipeline and make data quality, lineage, and ownership visible.

**Exit criteria:** an end-to-end Airflow DAG that is idempotent and backfillable; quality gates block bad data; lineage and catalog are browsable.

| Day | Focus & key concepts | Deliverable | Status |
|---|---|---|---|
| 1 | Airflow architecture: scheduler, executor, metadata DB, DAG parsing | Airflow in Compose (profile) | ⬜ |
| 2 | DAGs, dependencies, retries, idempotent tasks | First DAG | ⬜ |
| 3 | Data intervals, catchup, backfills | Backfill drill | ⬜ |
| 4 | End-to-end DAG: ingest → process → dbt → validate → publish | Main pipeline DAG | ⬜ |
| 5 | Data-aware scheduling, freshness checks, alerting | Freshness alerts | ⬜ |
| 6 | Great Expectations suites per layer | Quality gates | ⬜ |
| 7 | Data contracts, source-to-lakehouse reconciliation | Reconciliation report | ⬜ |
| 8 | OpenLineage for Airflow, Spark, dbt | Lineage events | ⬜ |
| 9 | OpenMetadata: catalog, ownership, glossary (resource-heavy) | Browsable catalog | ⬜ |
| 10 | Failure drills; retrospective | M7 docs | ⬜ |

---

## Milestone 8 — Production Readiness

**Goal:** Operate the platform: observe it, test it, deploy it, recover it.

**Exit criteria:** dashboards and alerts for key SLIs; CI on every push; targeted Kubernetes deployment; documented recovery runbooks; benchmarks at scale.

| Day | Focus & key concepts | Deliverable | Status |
|---|---|---|---|
| 1 | Metrics, logs, traces; SLIs and SLOs for data | SLO doc | ⬜ |
| 2 | Prometheus and exporters (databases, Kafka, Spark/Flink) | Metrics scraped | ⬜ |
| 3 | Grafana dashboards and alerts (lag, freshness, errors) | Dashboards + alerts | ⬜ |
| 4 | GitHub Actions: lint, tests, Compose validation, dbt build | CI pipeline | ⬜ |
| 5 | Secrets management and least-privilege review | Security review doc | ⬜ |
| 6 | Kubernetes fundamentals (kind/k3d); deploy generator + API | Manifests | ⬜ |
| 7 | Stateful data workloads on Kubernetes (operators) — targeted | One component on K8s | ⬜ |
| 8 | Backup, disaster recovery, replay; runbooks | Runbooks | ⬜ |
| 9 | Scale benchmark: 5–10M records (100M+ if hardware allows) | Benchmark report | ⬜ |
| 10 | Final review, docs polish, v1.0 release | Release | ⬜ |

---

## Decisions Log

| ADR | Title | Status |
|---|---|---|
| [0001](decisions/0001-two-independent-operational-databases.md) | Two independent operational databases (PostgreSQL + MySQL) | ✅ Accepted |

---

## Backlog & Open Questions

- Day 1: choose a license (MIT vs Apache-2.0).
- M2: Airbyte's local requirements may be too heavy for a laptop alongside the databases. Verify before Day 3.

---

## Learning Log

One entry per learning day. Write "What I learned" in your own words; that is the part that sticks.

**Template**

```markdown
### M?-D? — <title> · YYYY-MM-DD
- **Time spent:**
- **What I built:**
- **What I learned (own words):**
- **What broke & how I fixed it:**
- **Open questions:**
- **Next step:**
```

### M1-D1 — Project Setup & Docker Compose · started 2026-10-08

- **Time spent:**
- **What I built:** Repository, README, Compose file for PostgreSQL 16 + MySQL 8.4, `.env.example`, `.gitignore`, init scripts with `schema_migrations`, Makefile, ERD + ownership table, ADR-0001, Day 1 guide (EN + VI).
- **What I learned (own words):**
- **What broke & how I fixed it:**
  - `mapping key "volumes" already defined` — `mysql` and top-level `volumes` were indented under `postgres`. YAML indentation defines structure.
  - `postgres_data: /var/lib/...` with a space parses as a YAML mapping, not a `source:target` string.
  - Running `up` before the init SQL files existed made Docker create **directories** at those paths. Both init scripts failed, and on the next start the entrypoint skipped initialization because the data directory was no longer empty. Fix: create the real files and reset volumes with `down -v`.
  - MySQL exited with code 137 (128 + SIGKILL 9): it did not shut down within Docker's default 10 s stop timeout.
  - `.env` with real passwords was not ignored by git. Fixed `.gitignore`.
  - Hardened healthchecks to use TCP (`-h 127.0.0.1`): during init the temporary server listens on a socket only, so socket-based checks can pass too early.
- **Measured (idle, empty DBs):** PostgreSQL ~21 MiB RAM / 48 MB volume; MySQL ~431 MiB RAM / 218 MB volume. `make up` on a fresh volume: ~6 s to healthy.
- **Open questions:**
- **Next step:** Finish the remaining Day 1 tasks above.
