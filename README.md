# Ollama Coding

Docker Compose project to run Ollama with GPU support and public exposure via ngrok.

## 📋 Description

This project sets up a complete environment to run local language models using Ollama, with automatic hardware detection and optimized configuration based on available resources. Includes an ngrok tunnel for remote access.

## 🚀 Features

- **Automatic hardware detection**: Detects NVIDIA GPU and configures the model based on available VRAM
- **GPU support**: Automatic configuration to use NVIDIA GPU when available
- **Public tunnel**: ngrok integration to expose the service publicly
- **Data persistence**: Docker volumes to maintain downloaded models

## 📦 Prerequisites

- Docker and Docker Compose installed
- NVIDIA Docker Runtime (nvidia-docker2) if you want to use GPU
- ngrok account with authtoken (optional, only if using the ngrok service)

## 🛠️ Installation

1. Clone or download this repository:
```bash
git clone <repository-url>
cd ollama-coding
```

2. Configure your ngrok authtoken (if using the ngrok service):
   - Edit `docker-compose.yml` and replace `NGROK_AUTHTOKEN` with your token
   - Optionally, change the URL in the ngrok command

3. Start the services:
```bash
docker-compose up -d
```

## 📁 Project Structure

```
ollama-coding/
├── docker-compose.yml    # Docker services configuration
├── entrypoint.sh         # Initialization script with hardware detection
└── README.md            # This file
```

## 🔧 Configuration

### Models by Hardware

The `entrypoint.sh` script automatically selects the model based on available VRAM:

- **≥16GB VRAM**: `qwen3-coder:30b:Q4_K_M`
- **≥8GB VRAM**: `qwen3-coder:30b:IQ3_M`
- **<8GB VRAM**: `qwen3-coder:7b:Q4_0`

### Ports

- **Ollama**: `11434` (exposed on `localhost:11434`)
- **ngrok**: Exposes Ollama publicly according to configuration

### Volumes

- `ollama`: Persists downloaded models in `/root/.ollama`

## 🎯 Usage

### Start services

```bash
docker-compose up -d
```

### View logs

```bash
# Ollama logs
docker logs ollama-qwen3

# ngrok logs
docker logs ngrok-ollama
```

### Stop services

```bash
docker-compose down
```

### Stop and remove volumes

```bash
docker-compose down -v
```

### Use Ollama

Once started, you can use Ollama from:

- **Locally**: `http://localhost:11434`
- **Publicly**: URL provided by ngrok (check ngrok logs)

Example usage with curl:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "qwen3-coder:7b",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

## ⚙️ Environment Variables

### Ollama

- `OLLAMA_HOST`: Configured as `0.0.0.0` to accept external connections

### ngrok

- `NGROK_AUTHTOKEN`: ngrok authentication token (required)

## 🔒 Security

⚠️ **Important**: This project exposes Ollama publicly via ngrok. Make sure to:

- Use a valid ngrok authtoken
- Consider implementing additional authentication if exposing sensitive services
- Review and update the ngrok URL according to your needs

## 🐛 Troubleshooting

### GPU not detected

If you have an NVIDIA GPU but it's not detected:

1. Verify that nvidia-docker2 is installed:
```bash
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

2. Verify that Docker has GPU access:
```bash
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

### ngrok not working

- Verify that the authtoken is valid
- Check logs: `docker logs ngrok-ollama`
- Make sure the ollama service is running before starting ngrok

## 📝 Notes

- Models are automatically downloaded the first time you run it
- The download process may take several minutes depending on the model and your connection
- Models are stored in the Docker volume for persistence

## 📄 License

This project is open source. Adjust according to your preferred license.

## 🤝 Contributing

Contributions are welcome. Please:

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
