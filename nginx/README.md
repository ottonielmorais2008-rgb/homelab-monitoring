# Nginx reverse proxy

Puts Uptime Kuma behind Nginx on the Compose network.

| Path | Auth | Rate limit | Backend |
| --- | --- | --- | --- |
| `/health` | no | no | Nginx (`200 ok`) |
| `/` | basic (`monitor`) | 2 r/s | `uptime-kuma:3001` |

Demo credentials (local lab only): user `monitor`, password `changeme`.
Change them before exposing the stack on a real network.

Optional TLS: run `../scripts/generate-nginx-tls.sh`, copy
`conf.d/ssl.conf.example` to `conf.d/ssl.conf`, and restart Nginx.

Published docs: see the GitHub Pages site linked from the root README.
