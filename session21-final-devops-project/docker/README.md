# Docker setup

**Name:** Kartikey
**Roll number:** 24bcs10121

Build contexts are `../application/backend` and `../application/frontend`; each contains its Dockerfile and `.dockerignore`. The frontend uses a Node build stage and unprivileged Nginx runtime. The backend uses a non-root Python Alpine runtime. Dependencies are installed before source copy to reuse build layers.

From the project root, `docker compose up -d --build` starts PostgreSQL, migration, API and frontend in health-dependent order. `docker compose ps`, `docker compose logs backend`, and `docker compose exec backend id` verify readiness, logs and runtime identity. `docker compose down` preserves the named database volume; `down -v` deletes it.
