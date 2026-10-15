# OmniCommerce — Lộ trình tổng & Nhật ký học tập

> 🇬🇧 English version: [roadmap.md](roadmap.md)

File này là nguồn tham chiếu duy nhất cho **mỗi ngày cần làm gì**, **thế nào là "xong"**, và **đã học được gì**.

- Lịch trình chỉ để định hướng, không phải deadline. Một "ngày" là một đơn vị học, có thể kéo dài hơn một ngày thực tế.
- Chỉ tick task sau khi đã thực sự chạy và kiểm chứng.
- Milestone hiện tại có task chi tiết. Các milestone sau chỉ ghi trọng tâm và sản phẩm đầu ra của từng ngày, sẽ được viết chi tiết khi bắt đầu milestone đó.

**Chú thích trạng thái:** ⬜ Chưa bắt đầu · 🟨 Đang làm · ✅ Hoàn thành · ⏸ Tạm hoãn

---

## Tổng quan tiến độ

| # | Milestone | Tuần | Trạng thái | Bắt đầu | Hoàn thành |
|---|---|---|---|---|---|
| 1 | Nền tảng Data Engineering | 1–2 | 🟨 | 2026-10-08 | |
| 2 | Batch Ingestion & CDC | 3–4 | ⬜ | | |
| 3 | Kiến trúc Streaming | 5–6 | ⬜ | | |
| 4 | Data Lakehouse | 7–8 | ⬜ | | |
| 5 | Xử lý Batch & Stream | 9–10 | ⬜ | | |
| 6 | Data Modeling & Serving | 11–12 | ⬜ | | |
| 7 | Orchestration & Governance | 13–14 | ⬜ | | |
| 8 | Sẵn sàng Production | 15–16 | ⬜ | | |

**Đang tập trung:** M1 · Ngày 1 — Thiết lập dự án, Docker Compose, kiến trúc dữ liệu.

---

## Milestone 1 — Nền tảng Data Engineering

**Mục tiêu:** Có hai database vận hành thuộc sở hữu độc lập, môi trường local tái lập được, và các nguồn dữ liệu giả lập (batch, liên tục, API, file) để các milestone sau ingest.

**Tiêu chí hoàn thành milestone**

- [ ] Từ một bản clone mới, `cp .env.example .env && make up` khởi động PostgreSQL và MySQL ở trạng thái healthy.
- [ ] Schema có primary key, foreign key, constraint, và các index đều có lý do.
- [ ] Generator nạp khoảng 100k bản ghi, tái lập được (cùng seed cho ra cùng dữ liệu).
- [ ] Workload liên tục chạy với tốc độ cấu hình được và không chết khi database restart.
- [ ] Mock API và nguồn CSV/JSON phục vụ dữ liệu theo data contract đã viết.
- [ ] Bộ validation chạy pass, và phát hiện được dữ liệu hỏng.
- [ ] Số liệu benchmark lấy từ lần chạy thật, có ghi cấu hình phần cứng.
- [ ] Đã viết ADR-001 và có tài liệu bài học cho từng ngày.

### Ngày 1 — Thiết lập dự án, Docker Compose, kiến trúc dữ liệu · 🟨

**Mục tiêu học:** image vs container · named volume vs bind mount · publish port và bind `127.0.0.1` · healthcheck · nội suy biến từ `.env` (`$` vs `$$`) · cách entrypoint của database chạy init script · OLTP vs OLAP · vì sao quyền sở hữu database quan trọng.

**Task**

- [x] Tạo repository và push lên GitHub
- [x] Bản nháp README
- [x] `infrastructure/docker/compose.yml` cho PostgreSQL 16 và MySQL 8.4 (`docker compose config` chạy qua)
- [x] Thêm `.env.example`, git đã ignore `.env`
- [x] Thay hai thư mục `001_init.sql` (do Docker tạo ra) bằng file SQL thật
- [x] Reset volume (`docker compose down -v`) và khởi tạo lại sạch
- [x] Cả hai container báo `healthy` trong `docker compose ps`
- [x] Kết nối từ trong container (`psql`, `mysql`) và từ máy host (MySQL từ host: mới kiểm tra port, chưa cài client)
- [x] Test persistence: ghi một dòng → `down` → `up` → dòng đó vẫn còn
- [x] Đổi tên `MAKEFILE` → `Makefile`; thêm các target `up`, `down`, `ps`, `logs`, `psql`, `mysql`
- [ ] Thêm `LICENSE` (chờ quyết định: MIT hay Apache-2.0)
- [x] Mô hình dữ liệu khái niệm và ERD (Mermaid) trong `docs/architecture/data-model.md`
- [x] Bảng phân chia sở hữu database (service nào sở hữu entity nào)
- [x] ADR-0001: Hai database vận hành độc lập (`docs/decisions/`)
- [x] Bài học Ngày 1 trong `docs/milestones/01-foundations/` (EN + VI)
- [ ] (Bạn) Tự làm lại theo hướng dẫn; bài Phá & Sửa A–C
- [ ] (Bạn) Rà ERD và ADR-0001; phản biện bất cứ điểm nào bạn không đồng ý
- [ ] (Bạn) Viết phần "Điều tôi học được" trong nhật ký học tập
- [ ] Commit và push

**Definition of Done:** chu trình `down -v` → `up` cho ra hai database healthy, đã khởi tạo đầy đủ; test persistence pass; ERD và ADR-001 đã được commit.

### Ngày 2 — Schema, Constraint, Index · ⬜

**Mục tiêu học:** khoá (surrogate vs natural, `BIGINT IDENTITY` vs UUID) · `NOT NULL`, `UNIQUE`, `CHECK`, foreign key · kiểu dữ liệu cho tiền và thời gian (`NUMERIC`, `timestamptz`, UTC) · chuẩn hoá · B-tree index · `EXPLAIN ANALYZE` · ACID và ranh giới transaction.

- [ ] DDL PostgreSQL: `customers`, `orders`, `order_items`, `payments`
- [ ] DDL MySQL: `categories`, `products`, `inventory`
- [ ] Quy ước `created_at` / `updated_at` (cần cho incremental ingestion về sau)
- [ ] Index cho các query pattern chính; `EXPLAIN` trước và sau khi thêm mỗi index
- [ ] Test vi phạm constraint (insert dòng sai và xác nhận bị từ chối)
- [ ] Lưu ý: foreign key không thể nối giữa hai database; ghi lại cách giữ `order_items.product_id` nhất quán

**Definition of Done:** schema được áp dụng từ init script trên volume sạch; mỗi constraint có test insert-thất-bại; mỗi index có lý do và kết quả `EXPLAIN`.

### Ngày 3 — Synthetic Data Generator · ⬜

**Mục tiêu học:** seed tất định · phân phối thực tế (skew, khách hàng theo Pareto) · toàn vẹn tham chiếu giữa hai database · bulk loading (`COPY` / insert theo batch vs từng dòng).

- [ ] Project Python `apps/data-generator/` (file config, type hint, structured logging)
- [ ] Sinh categories, products, inventory, customers, orders, order items, payments
- [ ] Cùng seed cho ra output giống hệt (có test)
- [ ] Nạp khoảng 100k bản ghi; đo rows/giây khi insert từng dòng vs bulk loading
- [ ] Edge case: null ở field tuỳ chọn, đơn hàng rất lớn, khách hàng trông giống bị trùng

**Definition of Done:** `make seed` nạp được bộ dữ liệu tái lập; đã ghi lại throughput khi nạp.

### Ngày 4 — Workload giao dịch liên tục · ⬜

**Mục tiêu học:** state machine vòng đời đơn hàng · traffic update/delete (quan trọng cho CDC) · điều khiển tốc độ · tắt an toàn (graceful shutdown) · retry với backoff · idempotency.

- [ ] Vòng đời đơn hàng: `created → paid → shipped → delivered`, cùng `cancelled` và `payment_failed`
- [ ] Cập nhật khách hàng, đổi giá và xoá sản phẩm, thay đổi tồn kho
- [ ] Số event/giây cấu hình được (10, 100, 500)
- [ ] Retry với backoff khi mất kết nối; không retry vô hạn
- [ ] Ctrl+C dừng sạch, không để lại đơn hàng ghi dở

**Definition of Done:** workload chạy hơn 10 phút đúng tốc độ mục tiêu; restart database giữa chừng không làm nó crash hay hỏng dữ liệu.

### Ngày 5 — Mock REST API & nguồn file · ⬜

**Mục tiêu học:** API như một nguồn dữ liệu · phân trang · rate limit · cố ý gây lỗi (failure injection) · định dạng file (CSV vs JSON) và các bẫy thường gặp.

- [ ] `apps/mock-api/` (FastAPI): chiến dịch marketing và metric theo ngày của từng chiến dịch
- [ ] Phân trang, độ trễ cấu hình được, và gây lỗi có chủ đích (HTTP 429/500)
- [ ] File CSV/JSON lịch sử trong `data/samples/` (nhỏ, được commit)
- [ ] Data contract viết rõ cho từng endpoint và file

**Definition of Done:** API chạy qua Compose; file nạp được mà không cần sửa tay; contract đã có tài liệu.

### Ngày 6 — Validation & chất lượng dữ liệu · ⬜

**Mục tiêu học:** các chiều chất lượng dữ liệu (đầy đủ, duy nhất, hợp lệ, nhất quán, chính xác, độ tươi) · đối soát chéo giữa hai database.

- [ ] SQL check: dòng mồ côi (orphan), bản ghi trùng, số tiền âm, chuyển trạng thái không hợp lệ
- [ ] Check chéo database: mọi `product_id` trong đơn hàng đều tồn tại trong MySQL
- [ ] Bộ pytest chạy các check trên
- [ ] Cố ý chèn dữ liệu hỏng và xác nhận các check bắt được

**Definition of Done:** `make test` pass với dữ liệu sạch và fail với thông báo rõ ràng khi dữ liệu hỏng.

### Ngày 7 — Demo end-to-end, benchmark, tài liệu · ⬜

- [ ] `make demo`: up → seed → workload → validate
- [ ] Benchmark: throughput khi nạp, throughput của workload, dung lượng database — đo thật, không ước lượng
- [ ] Tài liệu Milestone 1 và cập nhật trạng thái trong README

**Definition of Done:** một người mới có thể làm theo tài liệu từ bản clone sạch đến bản demo chạy được.

### Ngày 8 — Đào sâu: Transaction, Isolation, Locking · ⬜

- [ ] Demo các isolation level (read committed vs repeatable read vs serializable)
- [ ] MVCC trong PostgreSQL vs InnoDB; lost update trên tồn kho; `SELECT … FOR UPDATE`
- [ ] Tái hiện và giải thích một deadlock

### Ngày 9 — Độ tin cậy của Generator · ⬜

- [ ] Chạy tiếp sau khi crash mà không sinh dữ liệu trùng
- [ ] Diễn tập lỗi: kill database giữa batch, gián đoạn mạng (`docker pause`)
- [ ] Structured log và các bộ đếm cơ bản (event đã gửi, thất bại, retry)

### Ngày 10 — Chuẩn bị CDC & tổng kết M1 · ⬜

- [ ] PostgreSQL: `wal_level=logical`, replication slot, `REPLICA IDENTITY`
- [ ] MySQL: binary log (định dạng ROW), GTID, `binlog_row_image`
- [ ] User CDC riêng với quyền tối thiểu
- [ ] Rà lại tiêu chí hoàn thành M1; viết bài tổng kết

---

## Milestone 2 — Batch Ingestion & CDC

**Mục tiêu:** Đưa dữ liệu ra khỏi database vận hành bằng batch (incremental) và CDC dựa trên log, hiểu rõ đánh đổi giữa hai cách.

**Tiêu chí hoàn thành:** cả incremental batch và CDC đều bắt được insert, update, delete; ingestion chạy lại được mà không sinh trùng; các bài diễn tập lỗi đã có tài liệu.

| Ngày | Trọng tâm & khái niệm chính | Sản phẩm | Trạng thái |
|---|---|---|---|
| 1 | Các pattern ingestion: full vs incremental, cursor, watermark, idempotency | Tài liệu khái niệm; quyết định landing zone (ADR) | ⬜ |
| 2 | Tự viết incremental ingestion (Python, cursor theo `updated_at`) | Script và demo những gì nó bỏ sót (hard delete, update đến muộn) | ⬜ |
| 3 | Cài Airbyte (tốn tài nguyên; kiểm tra yêu cầu trước); sync full refresh | Lần sync đầu tiên chạy được | ⬜ |
| 4 | Airbyte incremental và các chế độ dedup; test thay đổi schema | Báo cáo sync incremental | ⬜ |
| 5 | Lý thuyết CDC: WAL, binlog, query-based vs log-based, snapshot | Tài liệu khái niệm CDC | ⬜ |
| 6 | Kafka tối thiểu + Kafka Connect + Debezium connector cho PostgreSQL | Change event xuất hiện trong topic | ⬜ |
| 7 | Debezium connector cho MySQL; cấu trúc event (`before`/`after`/`op`/`source`) | Cả hai nguồn đều stream được | ⬜ |
| 8 | Offset của connector, restart, replication slot phình to khi connector ngừng | Bài viết diễn tập lỗi | ⬜ |
| 9 | Schema evolution, delete và tombstone, khử trùng lặp | Thí nghiệm thay đổi schema | ⬜ |
| 10 | Rà soát độ tin cậy; ADR: vai trò của Airbyte vs Debezium; tổng kết | ADR + tài liệu M2 | ⬜ |

---

## Milestone 3 — Kiến trúc Streaming

**Mục tiêu:** Hiểu sâu Kafka và xây pipeline sự kiện đáng tin cậy cho đơn hàng, tồn kho và hoạt động của khách hàng.

**Tiêu chí hoàn thành:** producer và consumer có delivery guarantee rõ ràng; schema được áp đặt; demo được replay và khôi phục; đo được lag khi chịu tải.

| Ngày | Trọng tâm & khái niệm chính | Sản phẩm | Trạng thái |
|---|---|---|---|
| 1 | Broker, topic, partition, offset, KRaft | Tài liệu thiết kế topic | ⬜ |
| 2 | Producer: key và thứ tự, partitioner, `acks`, idempotent producer, batching | Producer cho order event | ⬜ |
| 3 | Consumer, consumer group, rebalancing, chiến lược commit offset | Service consumer | ⬜ |
| 4 | Delivery semantics: at-most / at-least / exactly-once; transaction | Thí nghiệm minh hoạ từng loại | ⬜ |
| 5 | Schema Registry, Avro/Protobuf, các chế độ compatibility | Schema đã đăng ký + test thay đổi gây vỡ | ⬜ |
| 6 | Clickstream và app event; Fluent Bit cho log ứng dụng | Topic hoạt động người dùng và log | ⬜ |
| 7 | Retry, poison message, dead-letter topic | Luồng DLQ | ⬜ |
| 8 | Retention, log compaction, replay và khôi phục | Diễn tập replay | ⬜ |
| 9 | Replication nhiều broker, ISR, `min.insync.replicas`, broker chết | Thí nghiệm kill broker | ⬜ |
| 10 | Consumer lag, backpressure, throughput ở 10/100/500/1000 event/s; tổng kết | Kết quả benchmark | ⬜ |

---

## Milestone 4 — Data Lakehouse

**Mục tiêu:** Lưu dữ liệu ở định dạng mở trên object storage và xây các tầng Bronze / Silver / Gold trên Iceberg.

**Tiêu chí hoàn thành:** bảng Iceberg Bronze, Silver, Gold trên MinIO; thay đổi từ CDC được merge đúng vào Silver; demo được time travel, schema evolution và compaction.

| Ngày | Trọng tâm & khái niệm chính | Sản phẩm | Trạng thái |
|---|---|---|---|
| 1 | Object storage, S3 API, MinIO | MinIO trong Compose (profile) | ⬜ |
| 2 | Lưu theo dòng vs theo cột, cấu trúc Parquet, nén | Thí nghiệm dung lượng và tốc độ các định dạng file | ⬜ |
| 3 | Table format, metadata/manifest/snapshot của Iceberg, các lựa chọn catalog | ADR: Iceberg + lựa chọn catalog | ⬜ |
| 4 | Bronze: đưa CDC/event thô vào Iceberg (chọn engine ghi) | Bảng Bronze | ⬜ |
| 5 | Partitioning, hidden partitioning, partition evolution | Thí nghiệm partitioning | ⬜ |
| 6 | Silver: làm sạch, khử trùng, áp CDC bằng `MERGE INTO` | Bảng Silver | ⬜ |
| 7 | Gold: dataset sẵn sàng cho nghiệp vụ | Bảng Gold | ⬜ |
| 8 | Time travel, rollback, schema evolution | Notebook/script demo | ⬜ |
| 9 | Vấn đề file nhỏ, compaction, expire snapshot | Số liệu trước/sau | ⬜ |
| 10 | Benchmark lưu trữ; tổng kết | Tài liệu M4 | ⬜ |

---

## Milestone 5 — Xử lý Batch & Stream

**Mục tiêu:** Spark cho xử lý batch phân tán, Flink cho xử lý real-time có trạng thái.

**Tiêu chí hoàn thành:** pipeline Spark từ Bronze đến Gold có bằng chứng tuning; job Flink dùng window theo event time, có state và khôi phục được sau lỗi.

| Ngày | Trọng tâm & khái niệm chính | Sản phẩm | Trạng thái |
|---|---|---|---|
| 1 | Kiến trúc Spark: driver, executor, cluster manager | Spark cluster local | ⬜ |
| 2 | DataFrame, lazy evaluation, job/stage/task, Spark UI | Hướng dẫn đọc Spark UI có chú thích | ⬜ |
| 3 | Join, shuffle, broadcast join, data skew | Thí nghiệm join | ⬜ |
| 4 | Partitioning, bộ nhớ, AQE, tuning | Báo cáo tuning | ⬜ |
| 5 | Pipeline Spark chuẩn production: Bronze → Silver → Gold | Pipeline + test | ⬜ |
| 6 | Kiến trúc Flink: JobManager, TaskManager, slot | Flink cluster local | ⬜ |
| 7 | Event time vs processing time, watermark, window | Doanh thu real-time theo phút | ⬜ |
| 8 | Keyed state, timer | Phát hiện giỏ hàng bị bỏ dở | ⬜ |
| 9 | Checkpoint, savepoint, exactly-once sink, khôi phục sau lỗi | Diễn tập kill rồi khôi phục | ⬜ |
| 10 | Event đến muộn; benchmark; ADR: Spark + Flink; tổng kết | Tài liệu M5 | ⬜ |

---

## Milestone 6 — Data Modeling & Serving

**Mục tiêu:** Mô hình chiều (dimensional model) bằng dbt, phục vụ qua Trino và ClickHouse, trực quan hoá bằng Superset.

**Tiêu chí hoàn thành:** project dbt có test và tài liệu; đã xây fact, dimension và mart; dashboard trả lời được các câu hỏi nghiệp vụ; đánh đổi của tầng serving đã được đo.

| Ngày | Trọng tâm & khái niệm chính | Sản phẩm | Trạng thái |
|---|---|---|---|
| 1 | Dimensional modeling: grain, fact, dimension, star schema | Tài liệu thiết kế mô hình | ⬜ |
| 2 | Cài dbt và chọn engine thực thi; source và staging | ADR + staging model | ⬜ |
| 3 | `fact_orders`, `fact_order_items`, `fact_payments` | Fact model | ⬜ |
| 4 | `dim_customers` (SCD Type 2), `dim_products` | Dimension model + snapshot | ⬜ |
| 5 | Incremental model, test, tài liệu, lineage graph | `dbt build` pass | ⬜ |
| 6 | `mart_daily_revenue`, `mart_product_performance`, `mart_customer_behavior` | Mart | ⬜ |
| 7 | Trino: coordinator/worker, connector, federation, `EXPLAIN` | Trino truy vấn Iceberg | ⬜ |
| 8 | ClickHouse: MergeTree, ordering key, materialized view | Một số mart trong ClickHouse | ⬜ |
| 9 | Dashboard Superset | Dashboard doanh thu, sản phẩm, funnel | ⬜ |
| 10 | Benchmark truy vấn Trino vs ClickHouse; ADR; tổng kết | Tài liệu M6 | ⬜ |

---

## Milestone 7 — Orchestration & Governance

**Mục tiêu:** Điều phối toàn bộ pipeline, làm cho chất lượng dữ liệu, lineage và quyền sở hữu trở nên nhìn thấy được.

**Tiêu chí hoàn thành:** DAG Airflow end-to-end, idempotent và backfill được; quality gate chặn được dữ liệu xấu; duyệt được lineage và catalog.

| Ngày | Trọng tâm & khái niệm chính | Sản phẩm | Trạng thái |
|---|---|---|---|
| 1 | Kiến trúc Airflow: scheduler, executor, metadata DB, cách parse DAG | Airflow trong Compose (profile) | ⬜ |
| 2 | DAG, phụ thuộc giữa task, retry, task idempotent | DAG đầu tiên | ⬜ |
| 3 | Data interval, catchup, backfill | Diễn tập backfill | ⬜ |
| 4 | DAG end-to-end: ingest → process → dbt → validate → publish | DAG pipeline chính | ⬜ |
| 5 | Lập lịch theo dữ liệu (data-aware scheduling), kiểm tra độ tươi, cảnh báo | Cảnh báo độ tươi dữ liệu | ⬜ |
| 6 | Bộ Great Expectations cho từng tầng | Quality gate | ⬜ |
| 7 | Data contract, đối soát nguồn với lakehouse | Báo cáo đối soát | ⬜ |
| 8 | OpenLineage cho Airflow, Spark, dbt | Lineage event | ⬜ |
| 9 | OpenMetadata: catalog, quyền sở hữu, glossary (tốn tài nguyên) | Catalog duyệt được | ⬜ |
| 10 | Diễn tập lỗi; tổng kết | Tài liệu M7 | ⬜ |

---

## Milestone 8 — Sẵn sàng Production

**Mục tiêu:** Vận hành nền tảng: quan sát, kiểm thử, triển khai, khôi phục.

**Tiêu chí hoàn thành:** dashboard và cảnh báo cho các SLI chính; CI chạy mỗi lần push; triển khai Kubernetes có chọn lọc; runbook khôi phục đã có tài liệu; benchmark ở quy mô lớn.

| Ngày | Trọng tâm & khái niệm chính | Sản phẩm | Trạng thái |
|---|---|---|---|
| 1 | Metric, log, trace; SLI và SLO cho dữ liệu | Tài liệu SLO | ⬜ |
| 2 | Prometheus và exporter (database, Kafka, Spark/Flink) | Đã scrape được metric | ⬜ |
| 3 | Dashboard và cảnh báo Grafana (lag, độ tươi, lỗi) | Dashboard + cảnh báo | ⬜ |
| 4 | GitHub Actions: lint, test, validate Compose, dbt build | CI pipeline | ⬜ |
| 5 | Quản lý secret và rà soát quyền tối thiểu | Tài liệu rà soát bảo mật | ⬜ |
| 6 | Nền tảng Kubernetes (kind/k3d); triển khai generator + API | Manifest | ⬜ |
| 7 | Workload dữ liệu có trạng thái trên Kubernetes (operator) — có chọn lọc | Một thành phần chạy trên K8s | ⬜ |
| 8 | Backup, khôi phục thảm hoạ, replay; runbook | Runbook | ⬜ |
| 9 | Benchmark quy mô: 5–10 triệu bản ghi (100 triệu+ nếu phần cứng cho phép) | Báo cáo benchmark | ⬜ |
| 10 | Rà soát cuối, hoàn thiện tài liệu, phát hành v1.0 | Release | ⬜ |

---

## Nhật ký quyết định

| ADR | Tiêu đề | Trạng thái |
|---|---|---|
| [0001](decisions/0001-two-independent-operational-databases.md) | Hai database vận hành độc lập (PostgreSQL + MySQL) | ✅ Đã chấp nhận |

---

## Backlog & câu hỏi mở

- Ngày 1: chọn license (MIT hay Apache-2.0).
- M2: Airbyte có thể quá nặng để chạy trên laptop cùng với các database. Kiểm tra trước Ngày 3.

---

## Nhật ký học tập

Mỗi ngày học một mục. Phần "Điều tôi học được" hãy viết bằng lời của chính bạn; đó là phần giúp nhớ lâu nhất.

**Template**

```markdown
### M?-N? — <tiêu đề> · YYYY-MM-DD
- **Thời gian đã dùng:**
- **Đã xây dựng:**
- **Điều tôi học được (lời của mình):**
- **Lỗi gặp phải & cách sửa:**
- **Câu hỏi còn mở:**
- **Bước tiếp theo:**
```

### M1-N1 — Thiết lập dự án & Docker Compose · bắt đầu 2026-10-08

- **Thời gian đã dùng:**
- **Đã xây dựng:** Repository, README, file Compose cho PostgreSQL 16 + MySQL 8.4, `.env.example`, `.gitignore`, init script có `schema_migrations`, Makefile, ERD + bảng phân chia sở hữu, ADR-0001, bài hướng dẫn Ngày 1 (EN + VI).
- **Điều tôi học được (lời của mình):**
- **Lỗi gặp phải & cách sửa:**
  - `mapping key "volumes" already defined` — `mysql` và `volumes` cấp cao nhất bị thụt lề vào trong `postgres`. Trong YAML, thụt lề quyết định cấu trúc.
  - `postgres_data: /var/lib/...` có dấu cách sau dấu `:` nên bị parse thành một mapping YAML, không phải chuỗi `source:target`.
  - Chạy `up` khi file init SQL chưa tồn tại khiến Docker tạo **thư mục** tại các đường dẫn đó. Cả hai init script đều lỗi, và ở lần khởi động sau entrypoint bỏ qua bước khởi tạo vì data directory không còn trống. Cách sửa: tạo file thật và reset volume bằng `down -v`.
  - MySQL thoát với mã 137 (128 + SIGKILL 9): nó không tắt kịp trong thời gian chờ mặc định 10 giây của Docker.
  - `.env` chứa mật khẩu thật nhưng chưa được git ignore. Đã sửa `.gitignore`.
  - Gia cố healthcheck để dùng TCP (`-h 127.0.0.1`): trong lúc init, server tạm chỉ nghe trên socket, nên check qua socket có thể pass quá sớm.
- **Số đo (lúc rảnh, DB trống):** PostgreSQL ~21 MiB RAM / volume 48 MB; MySQL ~431 MiB RAM / volume 218 MB. `make up` trên volume mới: ~6 giây đến khi healthy.
- **Câu hỏi còn mở:**
- **Bước tiếp theo:** Hoàn thành các task còn lại của Ngày 1 ở trên.
