# ADR-0001: Two Independent Operational Databases (PostgreSQL + MySQL)

- **Status:** Accepted
- **Date:** 2026-10-15
- **Milestone:** M1 · Day 1

## Context

OmniCommerce needs operational (OLTP) source systems that later milestones ingest with batch tools, CDC, and streaming.

In real companies, operational data is rarely in one database. Different teams own different services, often on different database engines, and each team's database is optimized for its own application, not for analytics. Most of the hard problems in Data Engineering — integration, consistency, schema drift, CDC across engines — come from this fragmentation.

A learning platform that uses a single database would skip those problems.

## Decision

Run two independent operational databases, each owned by one fictional team:

| Database | Engine | Owns |
|---|---|---|
| `commerce` | PostgreSQL 16 | customers, orders, order_items, payments |
| `catalog` | MySQL 8.4 | categories, products, inventory |

Rules:

- Each database has exactly one writer team; nobody writes to another team's database.
- There are no cross-database foreign keys or transactions. References such as `order_items.product_id` are logical.
- Both run as separate containers with separate volumes in `infrastructure/docker/compose.yml`.

## Alternatives Considered

| Alternative | Why not chosen |
|---|---|
| One PostgreSQL database for everything | Simplest, but hides cross-system consistency problems and teaches CDC for only one engine. |
| One PostgreSQL instance, two schemas | Still allows cross-schema foreign keys and transactions, so the boundary is not real. |
| Two PostgreSQL instances | Realistic ownership split, but misses differences between engines (WAL vs binlog, type systems, Debezium connector behaviour). |
| PostgreSQL + a document store (e.g. MongoDB) | Valuable, but adds a second data model too early. Can be revisited as a challenge. |

## Rationale

- **Realism:** mirrors the "database per service" pattern common in microservice architectures.
- **Learning value:** PostgreSQL and MySQL are the two most common open-source OLTP engines, and both are first-class Debezium sources. Their CDC mechanisms (logical decoding of the WAL vs the row-based binlog) differ in ways worth learning.
- **Deliberate problems:** the missing shared transaction and foreign key create consistency issues that ingestion, validation, and modeling must handle later.

## Trade-offs

- More resources on a laptop: two database processes instead of one (acceptable; both are light at this data size).
- More configuration: two sets of credentials, init scripts, and health checks.
- SQL dialect differences: learners must handle both PostgreSQL and MySQL syntax.

## Consequences

- Cross-database integrity must be checked by validation (M1 Day 6) and reconciled downstream.
- CDC (M2) needs two connector configurations: PostgreSQL logical decoding and the MySQL binlog.
- Analytics that join orders with products can only happen after both sources are ingested into a shared platform (lakehouse, M4). This is the main reason the platform exists.
- Inventory overselling and partial failures between the databases are possible by design and become exercises.
