---
source_url: https://docs.immich.app/guides/remote-machine-learning
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Remote Machine Learning

## Overview

To address performance constraints on resource-limited systems like the Raspberry Pi, Immich allows you to host the machine learning container on a separate, more powerful system. The server container sends image previews to the remote ML container for processing, which does not retain or associate data with users.

### Feature Compatibility

"Smart Search and Face Detection will use this feature, but Facial Recognition will not." This distinction exists because facial recognition relies on previously saved model outputs stored in the database, making it a server-to-database operation.

### Security Considerations

**Important**: "Image previews are sent to the remote machine learning container. Use this option carefully when running this on a public computer or a paid processing cloud." The ML container lacks built-in security measures.

## Setup Instructions

1. Install Docker on the remote server
2. Deploy this `docker-compose.yml` configuration:

```yaml
name: immich_remote_ml
services:
  immich-machine-learning:
    container_name: immich_machine_learning
    image: ghcr.io/immich-app/immich-machine-learning:${IMMICH_VERSION:-release}
    volumes:
      - model-cache:/cache
    restart: always
    ports:
      - 3003:3003
volumes:
  model-cache:
```

3. Start the container: `docker compose up -d`
4. Navigate to Machine Learning Settings in the admin panel
5. Click "Add URL" and enter the remote container's address (e.g., `http://ip:port`)

### Version Alignment

"Version mismatches between both hosts may cause bugs and instability," requiring synchronized updates.

## Advanced Configurations

**Forcing Remote-Only Processing**: Replace the local URL entirely to disable fallback. This requires manually retrying failed jobs via the Job Status page if the remote server becomes unavailable.

**Load Balancing**: Multiple URLs are processed sequentially without load distribution. Use a dedicated load balancer for better resource allocation across multiple containers.
