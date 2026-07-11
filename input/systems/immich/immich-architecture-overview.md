---
source_url: https://docs.immich.app/developer/architecture/
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Architecture

Immich uses a traditional client-server design, with a dedicated database for data persistence. The frontend clients communicate with backend services over HTTP using REST APIs. Clients use OpenAPI to auto-generate REST clients.

## High Level Diagram

*(Diagram described in text.)* The high-level diagram shows clients (mobile app, web app, CLI) communicating with the server's API via REST. The server interfaces with downstream systems — Redis, Postgres, the Machine Learning service, and the file system — through repository interfaces. The diagram depicts the server running as two separate containers: `immich-server` and `immich-microservices`. The microservices container processes job requests from Redis rather than handling API requests or scheduling cron jobs.

> Note: the linked Administration > Jobs page (`/administration/jobs-workers`) describes the current packaging, where the `api` and `microservices` workers run inside the single `immich-server` container and can optionally be split via environment variables. See `immich-jobs-and-workers.md`.

## Clients

Immich has three main clients:

1. **Mobile app** — Android, iOS
2. **Web app** — responsive website
3. **CLI** — command-line utility for bulk upload

All three clients use [OpenAPI](https://docs.immich.app/api) to auto-generate REST clients for easy integration.

### Mobile App

The mobile app is written in [Dart](https://dart.dev/) using [Flutter](https://flutter.dev/). Below is a diagram of the architecture, described in text as a layered structure:

- **UI Layer**: Pages and Widgets
- **State Management**: Providers (using Riverpod)
- **Business Logic**: Services and Repositories
- **Data**: Models and Entities

The mobile app uses [Isar Database](https://isar.dev/) for local storage and [Riverpod](https://riverpod.dev/) for state management. Entities are persisted in the on-device database, while models remain ephemeral in memory. Repositories serve as the exclusive interface to data classes, and their public interfaces must not expose foreign data classes.

### Web Client

The web app is a [TypeScript](https://www.typescriptlang.org/) project that uses [SvelteKit](https://kit.svelte.dev/) and [Tailwindcss](https://tailwindcss.com/).

### CLI

The Immich CLI is an [npm](https://www.npmjs.com/) package that lets users control their Immich instance from the command line. It uses the API to perform various tasks, especially uploading assets. See the [CLI documentation](https://docs.immich.app/features/command-line-interface) for more information.

## Server

The backend is divided into several services, which run as individual Docker containers:

1. `immich-server` — handles REST API requests, and executes background jobs (thumbnail generation, metadata extraction, transcoding)
2. `immich-machine-learning` — executes machine learning models
3. `postgres` — persistent data storage
4. `redis` — queue management for background jobs

### Immich Server

The Immich Server is a [TypeScript](https://www.typescriptlang.org/) project written for [Node.js](https://nodejs.org/). It uses the [Nest.js](https://nestjs.com/) framework, with an [Express](https://expressjs.com/) server, and the [Kysely](https://kysely.dev/) query builder. The codebase follows [Hexagonal Architecture](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)) principles, separating technology-specific implementations (`src/repositories`) from core business logic (`src/services`).

#### API Endpoints

HTTP requests are mapped to controllers (`src/controllers`), which are collections of endpoints. Controllers usually implement the standard CRUD operations:

- `POST` `/<type>` — Create
- `GET` `/<type>` — Read (all)
- `GET` `/<type>/:id` — Read (by id)
- `PUT` `/<type>/:id` — Update (by id)
- `DELETE` `/<type>/:id` — Delete (by id)

#### Domain Transfer Objects (DTOs)

The server uses [Data transfer objects](https://en.wikipedia.org/wiki/Data_transfer_object) as public interfaces for the inputs (query, params, body) and outputs (responses) of each endpoint. DTOs are translated into [OpenAPI](https://docs.immich.app/api) schemas and control the generated code used by each client.

#### Background Jobs

Immich uses a worker to execute background jobs. These jobs include (see [Administration > Jobs](https://docs.immich.app/administration/jobs-workers/#jobs)):

- Thumbnail Generation
- Metadata Extraction
- Video Transcoding
- Smart Search
- Facial Recognition
- Storage Template Migration
- Sidecar ([XMP Sidecars](https://docs.immich.app/features/xmp-sidecars))
- Background jobs (file deletion, user deletion)

### Machine Learning

The machine learning service is written in [Python](https://www.python.org/) and uses [FastAPI](https://fastapi.tiangolo.com/) for HTTP communication. All ML-related operations are externalized to this service, `immich-machine-learning`, which allows it to be deployed separately from the server, or disabled entirely if needed.

Each request to the ML service includes the relevant metadata for the model task and the model name, with model settings stored in Postgres. The service downloads, loads, and configures the specified model before processing the request payload. Loaded models are cached and reused across requests. A thread pool processes requests in different threads so as not to block the async event loop.

All models are in ONNX format, which provides wide industry support and strong performance. Machine learning models are large and memory-intensive; optimization remains an ongoing focus.

### Postgres

Immich persists data in Postgres, which includes information about access and authorization, users, albums, assets, sharing settings, etc. See also [Database Migrations](https://docs.immich.app/developer/database-migrations).

### Redis

Immich uses Redis via [BullMQ](https://docs.bullmq.io/) to manage job queues. Some jobs trigger subsequent jobs — for example, Smart Search and Facial Recognition automatically execute after thumbnail generation completes.
