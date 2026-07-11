---
source_url: https://docs.immich.app/install/environment-variables
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate was stripped. Selection note — this page is long; the variable tables for docker-compose, general/server, workers, database, Redis, and machine learning are kept in full. Omitted sections — Ports, Prometheus, Docker Secrets setup details, and post-installation guidance.
---

# Environment Variables (Immich)

## Docker Compose Variables

| Variable | Description | Default | Containers |
|----------|-------------|---------|------------|
| `IMMICH_VERSION` | Image tags | `v3` | server, machine learning |
| `UPLOAD_LOCATION` | Host path for uploads | — | server |
| `DB_DATA_LOCATION` | Host path for Postgres database | — | database |

*Note: These variables are used by `docker-compose.yml` and do NOT affect containers directly.*

## General Variables

| Variable | Description | Default | Containers |
|----------|-------------|---------|------------|
| `TZ` | Timezone | *1 | server, microservices |
| `IMMICH_ENV` | Environment (production, development) | `production` | server, machine learning, api, microservices |
| `IMMICH_LOG_LEVEL` | Log level (verbose, debug, log, warn, error) | `log` | server, machine learning, api, microservices |
| `IMMICH_LOG_FORMAT` | Log output format (`console`, `json`) | `console` | server, api, microservices |
| `IMMICH_MEDIA_LOCATION` | Media location inside container | `/data` | server, api, microservices |
| `IMMICH_CONFIG_FILE` | Path to config file | — | server, api, microservices |
| `IMMICH_HELMET_FILE` | Path to helmet options JSON file | `false` | server, api |
| `NO_COLOR` | Disable color-coded log output | `false` | server, machine learning |
| `CPU_CORES` | Number of available cores | auto-detected | server |
| `IMMICH_API_METRICS_PORT` | OTEL metrics port | `8081` | server, api |
| `IMMICH_MICROSERVICES_METRICS_PORT` | OTEL metrics port | `8082` | server, microservices |
| `IMMICH_PROCESS_INVALID_IMAGES` | Generate thumbnails for invalid images | — | server, microservices |
| `IMMICH_TRUSTED_PROXIES` | Comma-separated trusted proxy IPs | — | server, api |
| `IMMICH_IGNORE_MOUNT_CHECK_ERRORS` | See System Integrity documentation | — | server, api, microservices |
| `IMMICH_ALLOW_SETUP` | Enable `/auth/admin-sign-up` endpoint | `true` | server, api |

## Workers Variables

| Variable | Description | Default | Containers |
|----------|-------------|---------|------------|
| `IMMICH_WORKERS_INCLUDE` | Only run these workers | — | server |
| `IMMICH_WORKERS_EXCLUDE` | Do not run these workers | — | server |

*Note: Information on current workers is available in the Jobs Workers documentation.*

## Database Variables

| Variable | Description | Default | Containers |
|----------|-------------|---------|------------|
| `DB_URL` | Database URL | — | server |
| `DB_HOSTNAME` | Database host | `database` | server |
| `DB_PORT` | Database port | `5432` | server |
| `DB_USERNAME` | Database user | `postgres` | server, database |
| `DB_PASSWORD` | Database password | `postgres` | server, database |
| `DB_DATABASE_NAME` | Database name | `immich` | server, database |
| `DB_SSL_MODE` | Database SSL mode | — | server |
| `DB_VECTOR_EXTENSION` | Vector extension (vectorchord or pgvector) | — | server |
| `DB_SKIP_MIGRATIONS` | Skip migrations on startup | `false` | server |
| `DB_STORAGE_TYPE` | Optimize for SSD or HDD | `SSD` | database |

*Note: All `DB_` variables must be provided to all Immich workers including `api` and `microservices`.*

## Redis Variables

| Variable | Description | Default | Containers |
|----------|-------------|---------|------------|
| `REDIS_URL` | Redis URL | — | server |
| `REDIS_SOCKET` | Redis socket | — | server |
| `REDIS_HOSTNAME` | Redis host | `redis` | server |
| `REDIS_PORT` | Redis port | `6379` | server |
| `REDIS_USERNAME` | Redis username | — | server |
| `REDIS_PASSWORD` | Redis password | — | server |
| `REDIS_DBINDEX` | Redis DB index | `0` | server |

*Note: All `REDIS_` variables must be provided to all Immich workers including `api` and `microservices`.*

## Machine Learning Variables

| Variable | Description | Default | Containers |
|----------|-------------|---------|------------|
| `MACHINE_LEARNING_MODEL_TTL` | Inactivity time (s) before model unload | `300` | machine learning |
| `MACHINE_LEARNING_MODEL_TTL_POLL_S` | Interval (s) between TTL checks | `10` | machine learning |
| `MACHINE_LEARNING_CACHE_FOLDER` | Model download directory | `/cache` | machine learning |
| `MACHINE_LEARNING_REQUEST_THREADS` | Request thread pool count | CPU core count | machine learning |
| `MACHINE_LEARNING_MODEL_INTER_OP_THREADS` | Parallel model operations | `1` | machine learning |
| `MACHINE_LEARNING_MODEL_INTRA_OP_THREADS` | Threads per model operation | `2` | machine learning |
| `MACHINE_LEARNING_WORKERS` | Worker processes to spawn | `1` | machine learning |
| `MACHINE_LEARNING_HTTP_KEEPALIVE_TIMEOUT_S` | HTTP keep-alive time (s) | `2` | machine learning |
| `MACHINE_LEARNING_WORKER_TIMEOUT` | Max unresponsiveness time (s) | `300` (900 for ROCm) | machine learning |
| `MACHINE_LEARNING_PRELOAD__CLIP__TEXTUAL` | Textual CLIP models to preload | — | machine learning |
| `MACHINE_LEARNING_PRELOAD__CLIP__VISUAL` | Visual CLIP models to preload | — | machine learning |
| `MACHINE_LEARNING_PRELOAD__FACIAL_RECOGNITION__RECOGNITION` | Facial recognition models to preload | — | machine learning |
| `MACHINE_LEARNING_PRELOAD__FACIAL_RECOGNITION__DETECTION` | Facial detection models to preload | — | machine learning |
| `MACHINE_LEARNING_PRELOAD__OCR__RECOGNITION` | OCR recognition models to preload | — | machine learning |
| `MACHINE_LEARNING_PRELOAD__OCR__DETECTION` | OCR detection models to preload | — | machine learning |
| `MACHINE_LEARNING_ANN` | Enable ARM-NN hardware acceleration | `True` | machine learning |
| `MACHINE_LEARNING_ANN_FP16_TURBO` | ARM-NN FP16 precision execution | `False` | machine learning |
| `MACHINE_LEARNING_ANN_TUNING_LEVEL` | ARM-NN GPU tuning level (1-3) | `2` | machine learning |
| `MACHINE_LEARNING_DEVICE_IDS` | Multi-GPU device IDs | `0` | machine learning |
| `MACHINE_LEARNING_MAX_BATCH_SIZE__FACIAL_RECOGNITION` | Max faces per batch | None (1 for OpenVINO) | machine learning |
| `MACHINE_LEARNING_MAX_BATCH_SIZE__OCR` | Max boxes per batch | `6` | machine learning |
| `MACHINE_LEARNING_RKNN` | Enable RKNN hardware acceleration | `True` | machine learning |
| `MACHINE_LEARNING_RKNN_THREADS` | RKNN runtime threads | `1` | machine learning |
| `MACHINE_LEARNING_MODEL_ARENA` | Pre-allocate CPU memory | `true` | machine learning |
| `MACHINE_LEARNING_OPENVINO_PRECISION` | OpenVINO precision (FP16 or FP32) | `FP32` | machine learning |
