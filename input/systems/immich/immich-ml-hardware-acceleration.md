---
source_url: https://docs.immich.app/features/ml-hardware-acceleration
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Hardware-Accelerated Machine Learning

This feature enables GPU acceleration for machine learning tasks like Smart Search and Facial Recognition, reducing CPU load. The capability is experimental and may not work universally across all systems.

## Supported Backends

- ARM NN (Mali)
- CUDA (NVIDIA GPUs with compute capability 5.2 or higher)
- ROCm (AMD GPUs)
- OpenVINO (Intel GPUs such as Iris Xe and Arc)
- RKNN (Rockchip)

## Limitations

- Configuration instructions are specific to Docker Compose; other container engines may differ
- Only Linux and Windows (via WSL2) servers are supported
- ARM NN requires Mali GPUs; other ARM devices aren't supported
- Model compatibility varies by backend; CUDA is most reliable
- ARM NN doesn't improve search latency due to model compatibility issues, though smart search jobs do benefit

## Prerequisites by Backend

**ARM NN:**
- Appropriate Linux kernel driver (usually pre-installed)
- `/dev/mali0` device must be available
- Closed-source `libmali.so` firmware required
- Optional: Configure `MACHINE_LEARNING_ANN_FP16_TURBO` for performance improvement

**CUDA:**
- GPU with compute capability 5.2+
- Official NVIDIA driver installed
- Driver version ≥ 545 (CUDA 12.3 support)
- Linux (except WSL2): NVIDIA Container Toolkit required

**ROCm:**
- Linux: AMDGPU driver module installed; secure boot requires DKMS key enrollment
- GPU must be ROCm-supported
- 35GiB minimum free disk space
- New backend; may experience issues (e.g., elevated power consumption)
- MIGraphX compiles models at runtime; initial inferences are slow

**OpenVINO:**
- Discrete GPUs more reliable than integrated ones
- Kernel version must support device acceleration
- Higher RAM usage than CPU processing

**OpenVINO-WSL:**
- Container must access `/dev/dri` directory
- May require group configuration via `getent group render` and `getent group video`

**RKNN:**
- Supported Rockchip SoCs: RK3566, RK3568, RK3576, RK3588
- Appropriate Linux kernel driver (usually pre-installed)
- RKNPU driver V0.9.8 or later
- Optional: `MACHINE_LEARNING_RKNN_THREADS` can improve performance (2-3 recommended for RK3576/RK3588)

## Setup

1. Download latest `hwaccel.ml.yml` and place alongside `docker-compose.yml`
2. Add backend identifier to `immich-machine-learning` image tag (e.g., `-cuda`)
3. Uncomment and update the `extends` section in `docker-compose.yml`
4. Redeploy the container

## Confirming Device Usage

Use GPU monitoring tools:
- `nvtop` for NVIDIA or Intel
- `intel_gpu_top` for Intel
- `radeontop` for AMD

Check `immich-machine-learning` logs for "Available ORT providers" or "Loaded ANN model" entries.

### Single Compose File Alternative

For platforms not supporting multiple Compose files, inline the hardware configuration directly into the service definition.

### Multi-GPU Support

Set `MACHINE_LEARNING_DEVICE_IDS` to comma-separated device IDs and `MACHINE_LEARNING_WORKERS` to device count:

```
MACHINE_LEARNING_DEVICE_IDS=0,1
MACHINE_LEARNING_WORKERS=2
```

## Tips

- Test different models if errors occur
- Increase concurrency for better utilization (increases VRAM consumption)
- Larger models benefit more from acceleration
- RKNPU vs. ARM NN comparison:
  - RKNPU: wider model support, less heat, lower accuracy
  - ARM NN: higher default precision (FP32)
  - Performance varies by thread configuration and concurrent workload
