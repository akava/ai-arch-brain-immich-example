---
source_url: https://docs.immich.app/install/kubernetes
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, footer) was stripped
---

# Kubernetes — Immich Installation

Immich can be deployed on Kubernetes using the official Helm chart from the `immich-charts` repository. Examples of how other people run Immich on Kubernetes can be found via kubesearch.dev.

The page itself is short: it points to the Helm chart as the supported route and carries one operational caveat.

## Known caveat — DNS resolution on Alpine images

The Alpine-based container images used by Immich "can encounter a DNS resolution bug on Kubernetes clusters if the host nodes have a search domain set."

Example of an affected node configuration:

```
$ cat /etc/resolv.conf
search home.lan
nameserver 192.168.1.1
```

This caveat is relevant when deploying Immich to Kubernetes environments where node-level search domains are configured.
