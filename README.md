# Vast.ai Kohya SS Docker Image

Simplified single Docker image for running Kohya SS Stable Diffusion training GUI on Vast.ai with integrated web-based management tools.

## Features

**All-in-one Docker image** with:
- **Kohya SS GUI** (port 8010): Stable Diffusion training interface with LoRA, DreamBooth, textual inversion, and fine-tuning
- **Filebrowser** (port 7010): File management interface for datasets, models, and outputs
- **ttyd** (port 7020): Web-based terminal (writable)
- **logdy** (port 7030): Log viewer for monitoring training progress
- **Python 3.11 + CUDA 12.2**: Optimized for stability and performance
- **UV Package Manager**: Fast dependency management
- **Simple process management**: No complex orchestration

## Quick Start

### For Vast.ai Users

1. Create a new instance with:
   ```
   Docker Image: ghcr.io/im/vastai-kohya-ss:latest
   ```

2. Configure environment variables and ports:
   ```bash
   -e USERNAME=admin -e PASSWORD=kohya -e OPEN_BUTTON_PORT=80 -p 80:80 -p 8010:8010 -p 7010:7010 -p 7020:7020 -p 7030:7030
   ```

3. Launch with "Entrypoint" mode for best compatibility

### Access Your Services

- **Landing Page**: OPEN_BUTTON_PORT (nginx homepage with links to all services)
- **Kohya SS GUI**: Port 8010 (main training interface, protected with Gradio auth)
- **File Manager**: Port 7010 (manage datasets, models and outputs, protected with auth)
- **Terminal**: Port 7020 (command line access, writable, protected with auth)
- **Logs**: Port 7030 (monitor training logs and system status)

## Default Credentials

- Username: `admin`
- Password: `kohya`

## Kohya SS Training Features

- **LoRA Training**: Train Low-Rank Adaptation models for efficient fine-tuning
- **DreamBooth**: Train custom models on specific subjects or styles
- **Textual Inversion**: Create custom embeddings for new concepts
- **Fine-tuning**: Full model fine-tuning for comprehensive customization
- **Multi-GPU Support**: Distributed training with Accelerate framework
- **Mixed Precision**: FP16/BF16/FP8 support for memory efficiency
- **Advanced Optimizers**: Support for AdamW, Lion, Prodigy, and more
- **Dataset Tools**: Built-in captioning, preprocessing, and validation

## Directory Structure

All data is stored in `/workspace/kohya_ss/`:

```
/workspace/
├── kohya_ss/
│   ├── models/          # Base models and checkpoints
│   ├── dataset/         # Training datasets with images and captions
│   ├── outputs/         # Trained models and LoRA files
│   ├── logs/           # Training logs and TensorBoard data
│   ├── reg/            # Regularization images
│   └── config/          # Training configuration files
└── logs/               # Service logs (nginx, kohya, filebrowser, etc.)
```

## Environment Variables

### Authentication
- `USERNAME`: Web interface username (default: `admin`)
- `PASSWORD`: Web interface password (default: `kohya`)

### Kohya SS Configuration
- `KOHYA_ARGS`: Additional arguments for Kohya SS GUI (optional)
- `WORKSPACE`: Data directory (default: `/workspace`)

### External Model Provisioning (Optional)
- `PROVISION_URL`: URL to model configuration file for automatic downloads (optional)
- `HF_TOKEN`: HuggingFace access token for gated models (optional)
- `CIVITAI_TOKEN`: CivitAI API token for downloading models (optional)

### System
- `OPEN_BUTTON_PORT`: Landing page port for Vast.ai (default: `80`)
- `NO_TCMALLOC`: Disable TCMalloc memory optimization (optional)

## Training Workflow

1. **Upload Base Model**: Upload checkpoint files to `/workspace/kohya_ss/models/`
2. **Prepare Dataset**: 
   - Upload training images to `/workspace/kohya_ss/dataset/` 
   - Follow Kohya's folder structure: `[number]_[concept_name]` (e.g., `30_cat`)
   - Add caption files (.txt) alongside images
3. **Setup Regularization** (optional): Add regularization images to `/workspace/kohya_ss/reg/`
4. **Configure Training**: Set up training parameters through the Kohya SS GUI
5. **Monitor Progress**: View training logs and TensorBoard data in Log Viewer (port 7030)
6. **Download Results**: Retrieve trained LoRA/models from `/workspace/kohya_ss/outputs/`

### Optional: External Model Provisioning

You can automatically download base models during container startup by setting `PROVISION_URL` to point to a configuration file:

```bash
-e PROVISION_URL=https://your-server.com/models.toml
-e HF_TOKEN=your_huggingface_token  # For gated models
-e CIVITAI_TOKEN=your_civitai_token # For CivitAI models
```

See `examples/provision-config.toml` for configuration format.

## Data Persistence

Mount volumes to preserve your work:

```bash
# For local Docker usage
-v /path/to/your/data:/workspace

# Volume structure
workspace/
├── kohya_ss/          # All Kohya SS data
└── logs/              # Service logs
```

## Development and Customization

### Building Locally

```bash
git clone https://github.com/im/vastai-kohya-ss.git
cd vastai-kohya-ss
docker build -t kohya-ss:local .
```

### Running Locally

```bash
docker run -d \
  --name kohya-ss \
  --gpus all \
  -p 80:80 -p 8010:8010 -p 7010:7010 -p 7020:7020 -p 7030:7030 \
  -e USERNAME=admin \
  -e PASSWORD=kohya \
  -v /path/to/data:/workspace \
  kohya-ss:local
```

## GPU Requirements

- **Minimum**: NVIDIA GPU with 8GB VRAM
- **Recommended**: RTX 3080/4080/4090 or better with 12GB+ VRAM
- **CUDA**: Compatible with CUDA 12.2+
- **Drivers**: NVIDIA drivers 525.60.13 or newer

## Training Tips

### Memory Optimization
- Use gradient checkpointing for large models
- Enable xformers for memory efficiency
- Adjust batch size based on VRAM capacity
- Use mixed precision (FP16) to reduce memory usage

### Performance
- Use NVMe SSD storage for datasets
- Enable TCMalloc for better memory allocation
- Monitor GPU utilization through terminal
- Use multiple workers for data loading

### Best Practices
- Start with small learning rates (1e-4 to 1e-5)
- Use proper regularization to prevent overfitting
- Validate training progress with sample generations
- Save checkpoints regularly during long training runs

## Troubleshooting

### Common Issues

**Kohya SS not starting**:
- Check logs: `docker logs <container_name>`
- Verify GPU access: `nvidia-smi` in terminal
- Ensure sufficient disk space for models

**Training crashes**:
- Reduce batch size or learning rate
- Check dataset format and captions
- Monitor VRAM usage during training

**Slow training**:
- Enable xformers and mixed precision
- Optimize dataset loading parameters
- Check storage I/O performance

### Support Resources

- [Kohya SS Documentation](https://github.com/bmaltais/kohya_ss)
- [Stable Diffusion Training Guide](https://github.com/huggingface/diffusers/tree/main/examples)
- [Vast.ai Documentation](https://docs.vast.ai)

## Security Considerations

- Change default credentials in production
- Use strong passwords for authentication
- Limit network access to required ports
- Regularly update the container image
- Backup training data and models

## License

This project packages Kohya SS and supporting tools. Individual components maintain their respective licenses:

- Kohya SS: [Apache 2.0](https://github.com/bmaltais/kohya_ss/blob/master/LICENSE.md)
- Container infrastructure: MIT License

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with a local build
5. Submit a pull request

---

**Built for the Stable Diffusion training community** 🎨
