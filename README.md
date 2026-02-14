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

## Docker Compose instructions

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

## Docker run commands (no compose)

1. Build or pull the dnscrypt-proxy image:
   ```bash
   docker pull ghcr.io/wickedyoda/pihole-doh-dnscrypt-proxy:latest
   ```
2. Create a dedicated Docker network:
   ```bash
   docker network create pihole-doh
   ```
3. Run dnscrypt-proxy:
   ```bash
   docker run -d \
     --name dnscrypt-proxy \
     --network pihole-doh \
     -e DNSCRYPT_LISTEN_ADDRESS=0.0.0.0:5053 \
     -e DOH_SERVER_NAME=custom-doh \
     -e DOH_SERVER_STAMP='sdns://REPLACE_WITH_YOUR_DOH_STAMP' \
     -e DNSCRYPT_BOOTSTRAP_RESOLVERS='9.9.9.9:53,1.1.1.1:53' \
     --restart unless-stopped \
     ghcr.io/wickedyoda/pihole-doh-dnscrypt-proxy:latest
   ```
4. Run Pi-hole pointed at dnscrypt-proxy:
   ```bash
   mkdir -p ./etc-pihole
   docker run -d \
     --name pihole \
     --hostname pihole \
     --network pihole-doh \
     -p 53:53/tcp \
     -p 53:53/udp \
     -p 80:80/tcp \
     -p 443:443/tcp \
     -e TZ='UTC' \
     -e FTLCONF_webserver_api_password='change-me' \
     -e FTLCONF_dns_listeningMode='ALL' \
     -e FTLCONF_dns_upstreams='dnscrypt-proxy#5053' \
     -v "$(pwd)/etc-pihole:/etc/pihole" \
     --cap-add NET_ADMIN \
     --cap-add SYS_TIME \
     --cap-add SYS_NICE \
     --restart unless-stopped \
     pihole/pihole:latest
   ```

## Verify upstream path

If using Docker Compose:

```bash
docker compose logs dnscrypt-proxy
docker compose exec pihole pihole -t
```

If using `docker run`:

```bash
docker logs dnscrypt-proxy
docker exec pihole pihole -t
```

Pi-hole should forward to `dnscrypt-proxy#5053` (configured via `FTLCONF_dns_upstreams`).

## GitHub Packages auto-build

This repo includes a workflow at:
- `.github/workflows/publish-dnscrypt-proxy.yml`
- `.github/workflows/publish-dnscrypt-proxy-beta.yml`

On every push to `main`, GitHub Actions builds `dnscrypt-proxy/Dockerfile` and pushes to GHCR:
- `ghcr.io/wickedyoda/pihole-doh-dnscrypt-proxy:latest`
- `ghcr.io/wickedyoda/pihole-doh-dnscrypt-proxy:<YYYYMMDD-HHMMSS>-main`
- Each tag is published as a multi-arch image (`linux/amd64` and `linux/arm64`)

For manual beta builds from your current branch, run:
- Workflow: `Publish dnscrypt-proxy beta image`
- Branch: choose the branch you want to build

Manual beta tags:
- `ghcr.io/wickedyoda/pihole-doh-dnscrypt-proxy:latest-<branch>` (or `latest` when run on `main`)
- `ghcr.io/wickedyoda/pihole-doh-dnscrypt-proxy:<YYYYMMDD-HHMMSS>-<branch>`
- Each tag is published as a multi-arch image (`linux/amd64` and `linux/arm64`)

Notes:
- It uses `secrets.GITHUB_TOKEN` (no extra PAT required for publishing from the same repo).
- Ensure GitHub Actions is enabled for the repository.
