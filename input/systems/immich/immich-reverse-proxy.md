---
source_url: https://docs.immich.app/administration/reverse-proxy
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged — full nginx/Caddy/Apache/Traefik config blocks condensed to their load-bearing directives and values; requirements kept verbatim where quoted.
---

# Reverse Proxy (Immich)

First-party guidance for putting a custom reverse proxy in front of Immich.

## Hard requirements

- The proxy must forward all headers and correctly set `Host`, `X-Real-IP`, `X-Forwarded-Proto`, and `X-Forwarded-For`.
- The proxy must allow sufficiently large file uploads.
- Sub-path serving is unsupported: "Immich does not support being served on a sub-path such as `location /immich {`. It has to be served on the root path of a (sub)domain."
- With Let's Encrypt http-01 challenges, the `/.well-known/immich` endpoint must still route to Immich, otherwise mobile app connections break.

## Nginx (key directives)

- `client_max_body_size 50000M` — upload size headroom
- `proxy_request_buffering off` — stream uploads instead of buffering in proxy memory
- `client_body_buffer_size 1024k`
- `proxy_read_timeout 600s`, `proxy_send_timeout 600s`, `send_timeout 600s`
- WebSocket support: HTTP/1.1 with `Upgrade`/`Connection` headers

## Caddy

- Minimal config; automatic HTTPS out of the box.

## Apache

- `ProxyPass` with 600-second timeouts and WebSocket upgrade support.

## Traefik (v3)

- Set entrypoint `respondingTimeouts` to 600 seconds — otherwise video uploads fail after one minute (default timeout).
- Service wiring done via docker-compose labels.
