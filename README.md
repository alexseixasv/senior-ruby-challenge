# FlowOps

FlowOps is a small B2B application for invoice operations. Teams use it to review invoices, receive payment webhooks from the fictional provider Northstar Pay, and extract invoice fields from documents with a local AI adapter.

This repository is a working service with a Rails API, a React dashboard, PostgreSQL, Redis, and Sidekiq. It is intended as a senior engineering working session. The product surface is intentionally narrow.

## Stack

- Ruby 3.3, Rails 7.2, PostgreSQL 16, Redis 7, Sidekiq, RSpec
- React 18, TypeScript, Vite, React Router, TanStack Query, Vitest
- Docker Compose

No paid API key is required. The default AI provider is an in-process mock.

## Prerequisites

- Docker Desktop with Docker Compose v2
- GNU Make, optional. The same steps are listed below as `docker compose` commands
- Ports 3000, 5173, 5432, and 6379 available locally

## Quick start

```bash
docker compose up --build -d --wait
docker compose exec backend ruby bin/rails db:seed
docker compose exec -e RAILS_ENV=test backend ruby bin/rails db:prepare
```

Or:

```bash
make setup
```

- API: http://localhost:3000
- Dashboard: http://localhost:5173
- Health: http://localhost:3000/up

`make setup` builds the containers, waits until the API is healthy, loads deterministic demo data, and prepares the test database.

## Environment

Defaults live in `docker-compose.yml` and are documented in `.env.example`. You do not need to create an `.env` file for local Docker.

| Variable | Purpose |
| --- | --- |
| `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD` | PostgreSQL connection |
| `REDIS_URL` | Sidekiq and the Rails Sidekiq client |
| `SECRET_KEY_BASE` | Rails secret |
| `PAYMENTS_WEBHOOK_TOKEN` | Shared token for `X-Webhook-Token` |
| `AI_PROVIDER` | `mock` (default) or `openai` |
| `AI_TIMEOUT_SECONDS` | Extraction timeout budget |
| `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL` | Optional OpenAI-compatible adapter. Leave the key empty |
| `VITE_API_URL` | Browser-facing API origin |
| `CORS_ORIGINS` | Allowed browser origin |

Demo requests authenticate with `Authorization: Bearer demo-account-{id}` after the database is seeded. Account 1 is Northwind Logistics, account 2 is Brightline Health, and account 3 is Cedar & Co.

## Database and seed data

Migrations run automatically when the API container starts.

The seed task **replaces** development data. It is deterministic: 3 accounts, 13 customers, 300 invoices, payment history for processed invoices, and 30 documents. Running it twice produces the same rows and ids.

```bash
make seed
```

```bash
docker compose exec backend ruby bin/rails db:seed
```

## Application surfaces

- `GET /api/dashboard/summary`
- `GET /api/invoices`
- `GET /api/invoices/:id`
- `POST /api/invoices`
- `PATCH /api/invoices/:id`
- `POST /api/webhooks/payments`
- `GET /api/documents/:id`
- `POST /api/documents/:id/process`

Example:

```bash
curl -H "Authorization: Bearer demo-account-1" http://localhost:3000/api/dashboard/summary
curl -H "Authorization: Bearer demo-account-1" http://localhost:3000/api/invoices
```

Successful payment webhook:

```bash
curl -X POST http://localhost:3000/api/webhooks/payments \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Token: dev-webhook-token" \
  -d "{\"id\":\"evt-manual-1\",\"type\":\"payment.succeeded\",\"provider\":\"northstar_pay\",\"data\":{\"invoice_id\":1,\"amount_cents\":1000}}"
```

Use an invoice id from the seeded account you intend to touch. Document processing is asynchronous: the process endpoint enqueues a Sidekiq job, and the document endpoint shows the stored result after the worker finishes.

## Tests

Baseline tests cover behavior that already works. Challenge tests describe the reported production issues and **fail on a fresh checkout**.

Backend baseline:

```bash
docker compose exec -e RAILS_ENV=test backend bundle exec rspec spec/models spec/requests spec/services spec/jobs
```

Backend challenge:

```bash
docker compose exec -e RAILS_ENV=test backend bundle exec rspec spec/challenges
```

Frontend baseline and challenge:

```bash
docker compose exec frontend npm test
docker compose exec frontend npm run test:challenge
```

Both suites:

```bash
make test
make test-challenge
```

Prepare the test database once, after the API is up:

```bash
docker compose exec -e RAILS_ENV=test backend ruby bin/rails db:prepare
```

`make setup` and `make reset` already do this.

## Other commands

```bash
make up
make down
make logs
make reset
```

`make reset` deletes the database volume, starts clean containers, seeds development data, and prepares the test database.

## Troubleshooting

- If `http://localhost:3000/up` is not healthy, inspect `docker compose logs backend`. The API waits for PostgreSQL and then runs `db:prepare`.
- Sidekiq starts after the API is healthy. Restart it after changing job code: `docker compose restart sidekiq`.
- If port 5432 or 6379 is already taken, stop the local service or change the published port in `docker-compose.yml`.
- The dashboard calls `http://localhost:3000` from the browser. `VITE_API_URL` must stay on localhost, not the Docker service name.
- Challenge failures are expected before the working session. Baseline failures are not.
- An OpenAI key is not required. Do not point `AI_PROVIDER` at `openai` unless you are explicitly exercising that adapter.

## Candidate session

See [docs/candidate-instructions.md](docs/candidate-instructions.md) and [docs/architecture.md](docs/architecture.md).
