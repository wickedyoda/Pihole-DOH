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
