# Pihole-DOH

Pi-hole (latest official container) with `dnscrypt-proxy` as upstream DNS-over-HTTPS.

## What this stack does

- Runs `pihole/pihole:latest`.
- Routes Pi-hole upstream DNS to an internal `dnscrypt-proxy` container.
- Lets you set your own DoH server via `DOH_SERVER_STAMP` in `.env`.

## Files

- `docker-compose.yml`: Pi-hole + dnscrypt-proxy services.
- `dnscrypt-proxy/Dockerfile`: local dnscrypt-proxy runtime image.
- `dnscrypt-proxy/entrypoint.sh`: renders config from environment variables.
- `dnscrypt-proxy/dnscrypt-proxy.toml.tpl`: dnscrypt-proxy template.
- `.env.example`: environment variables you should customize.

## Setup

1. Create your env file:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` and set at least:
   - `PIHOLE_WEBPASSWORD`
   - `DOH_SERVER_STAMP` (must be an `sdns://...` DNS stamp for your DoH endpoint)
3. Start:
   ```bash
   docker compose up -d --build
   ```
4. Open Pi-hole admin:
   - [http://localhost/admin](http://localhost/admin)

## Verify upstream path

```bash
docker compose logs dnscrypt-proxy
docker compose exec pihole pihole -t
```

Pi-hole should forward to `dnscrypt-proxy#5053` (configured via `FTLCONF_dns_upstreams`).

## GitHub Packages auto-build

This repo includes a workflow at:
- `.github/workflows/publish-dnscrypt-proxy.yml`
- `.github/workflows/publish-dnscrypt-proxy-beta.yml`

On every push to `main`, GitHub Actions builds `dnscrypt-proxy/Dockerfile` and pushes to GHCR:
- `ghcr.io/<your-org-or-user>/pihole-doh-dnscrypt-proxy:latest`
- `ghcr.io/<your-org-or-user>/pihole-doh-dnscrypt-proxy:<YYYYMMDD-HHMMSS>-main`
- Each tag is published as a multi-arch image (`linux/amd64` and `linux/arm64`)

For manual beta builds from your current branch, run:
- Workflow: `Publish dnscrypt-proxy beta image`
- Branch: choose the branch you want to build

Manual beta tags:
- `ghcr.io/<your-org-or-user>/pihole-doh-dnscrypt-proxy:latest-<branch>` (or `latest` when run on `main`)
- `ghcr.io/<your-org-or-user>/pihole-doh-dnscrypt-proxy:<YYYYMMDD-HHMMSS>-<branch>`
- Each tag is published as a multi-arch image (`linux/amd64` and `linux/arm64`)

Notes:
- It uses `secrets.GITHUB_TOKEN` (no extra PAT required for publishing from the same repo).
- Ensure GitHub Actions is enabled for the repository.
