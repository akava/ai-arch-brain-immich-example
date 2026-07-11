---
source_url: https://docs.immich.app/features/hardware-transcoding
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Hardware Transcoding

## Overview

"This feature allows you to use a GPU to accelerate transcoding and reduce CPU load." However, hardware transcoding typically produces larger videos with lower quality compared to software transcoding. The feature remains experimental and may not work universally across all systems.

Note: Previously completed transcoding jobs don't require redoing after enabling hardware acceleration.

## Supported APIs

- NVENC (NVIDIA)
- Quick Sync (Intel)
- RKMPP (Rockchip)
- VAAPI (AMD / NVIDIA / Intel)

## Limitations

- Docker Compose-specific; other container engines may need different configuration
- Only Linux and Windows (WSL2) servers supported
- WSL2 doesn't support Quick Sync
- Raspberry Pi unsupported
- Two-pass mode only works with NVENC
- "By default, only encoding is currently hardware accelerated" — CPU handles decoding and tone-mapping
- Hardware-dependent codec support; H.264 and HEVC usually supported
- NVIDIA and AMD GPUs don't support VP9 encoding
- Newer devices generally provide better transcoding quality

## Prerequisites

### NVENC
- Official NVIDIA driver required
- Linux (non-WSL2) requires NVIDIA Container Toolkit

### QSV
- VP9 requires 9th gen Intel CPU or newer
- 11th gen or older may need Low-Power mode
- 11th gen on kernel 5.15 requires kernel upgrade

### RKMPP
- Supported Rockchip ARM SoC required
- Only RK3588 supports hardware tonemapping
- Requires `/usr/lib/aarch64-linux-gnu/libmali.so.1` for tonemapping
- Specific OpenCL configuration lines must be uncommented in `hwaccel.transcoding.yml`

## Setup

### Basic Setup

1. Download latest `hwaccel.transcoding.yml` file into same folder as `docker-compose.yml`
2. Uncomment `extends` section in `docker-compose.yml` under `immich-server`; change `cpu` to appropriate backend
3. Redeploy `immich-server` container
4. In Admin page under Video transcoding settings, select appropriate hardware acceleration option
5. Optionally enable hardware decoding

### Configuration File Alternative

Using `immich.json`:

```json
{
  "ffmpeg": {
    "accel": "qsv",
    "accelDecode": true
  }
}
```

### Single Compose File Method

Inline `hwaccel.transcoding.yml` contents directly into `immich-server` service for platforms not supporting multiple Compose files.

Example for QSV:

```yaml
immich-server:
  devices:
    - /dev/dri:/dev/dri
```

### Unraid Setup

**QSV:**
- Add Device: `/dev/dri`

**NVENC:**
- Add environment variable: `NVIDIA_VISIBLE_DEVICES=all`
- Add Extra Parameters: `--runtime=nvidia`

## Tips

- Use slower presets than software transcoding to maintain quality
- Prefer specific APIs (NVENC/QSV) over VAAPI for optimized performance
- Verify utilization with monitoring tools (`nvtop`, `intel_gpu_top`)
- Absence of error logs during transcoding indicates successful use
