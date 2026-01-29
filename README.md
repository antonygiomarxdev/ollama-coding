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

2. Configure environment variables:
   - Copy `.env.example` to `.env` (e.g. `cp .env.example .env` or on Windows: `copy .env.example .env`)
   - Edit `.env` and set `NGROK_AUTHTOKEN` (get it from [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken))
   - Optionally set `NGROK_DOMAIN` for a reserved domain, or leave empty for a random URL

3. Start the services:
```bash
docker-compose up -d
```

## 📁 Project Structure

```
ollama-coding/
├── .env                  # Your secrets (create from .env.example, do not commit)
├── .env.example          # Template for environment variables
├── docker-compose.yml    # Docker services configuration
├── entrypoint.sh         # Ollama initialization script with hardware detection
├── ngrok-entrypoint.sh   # Ngrok wrapper (optional reserved domain)
└── README.md             # This file
```

## 🔧 Configuration

### Models by Hardware

The `entrypoint.sh` script automatically selects the model based on available VRAM (unless you set `OLLAMA_MODEL`):

- **≥16GB VRAM**: `qwen3-coder:30b:Q4_K_M`
- **≥8GB VRAM**: `qwen3-coder:30b:IQ3_M`
- **<8GB VRAM**: `qwen3-coder:7b:Q4_0`

### Using Other Models

If you prefer a different model (e.g. `llama3.2`, `mistral`, `codellama`, `deepseek-coder`):

1. **Override at startup**: Set `OLLAMA_MODEL` in `.env` (e.g. `OLLAMA_MODEL=llama3.2`). The entrypoint will pull and use that model instead of the hardware-based default.
2. **Pull more models later**: Once the stack is running, you can pull extra models via the API or from the host:
   - **From host**: `curl -X POST http://localhost:11434/api/pull -d '{"model":"mistral"}'`
   - **Inside container**: `docker exec ollama-qwen3 ollama pull mistral`
3. **Browse the library**: [Ollama Model Library](https://ollama.com/library) lists all official models and tags (e.g. `llama3.2`, `qwen2.5-coder`, `codellama`). Use the exact name in `OLLAMA_MODEL` or in `/api/pull`.

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

## 🖥️ IDE Integration

Use this Ollama instance as the backend for AI features in your editor. Base URL:

- **Local**: `http://localhost:11434`
- **Remote (ngrok)**: `https://<your-ngrok-domain>` (e.g. from `docker logs ngrok-ollama`)

Ollama exposes an **OpenAI-compatible** API at `/v1` (e.g. `http://localhost:11434/v1`). Prefer that when the IDE supports “OpenAI-compatible” or “Custom endpoint”.

### Cursor

1. Open **Settings** → **Cursor Settings** → **Models** (or **Features** → **Models**).
2. Add a **Custom** / **OpenAI-compatible** model.
3. Set:
   - **API Base URL**: `http://localhost:11434/v1`
   - **API Key**: `ollama` (Ollama ignores it; some clients require a non-empty value).
4. Choose the model name that matches your container (e.g. `qwen3-coder:7b`, `qwen3-coder:30b:IQ3_M`).

For a **remote** machine (e.g. another PC that reaches this server via ngrok):

- **API Base URL**: `https://<your-ngrok-domain>/v1` (same API key).

### VS Code (Continue / Ollama)

- **Continue**: In the Continue extension, add the **Ollama** provider. Set the server URL to `http://localhost:11434` (or your ngrok URL). Select the same model name as in Ollama (e.g. `qwen3-coder:7b`).
- **Ollama extension**: Usually uses `http://localhost:11434` by default. If the editor runs on another machine, set the env var or extension setting to your ngrok URL (e.g. `https://<your-ngrok-domain>`).

### JetBrains (IntelliJ, PyCharm, etc.)

- Use a plugin that supports **OpenAI-compatible** or **Ollama** backends.
- Set the base URL to `http://localhost:11434/v1` (or `https://<your-ngrok-domain>/v1` for remote).
- Use API key `ollama` if the plugin requires one.
- Model name must match exactly (e.g. `qwen3-coder:7b`).

### Checking the model name

Containers use the name chosen by `entrypoint.sh` (see [Models by Hardware](#models-by-hardware)). List models from the host:

```bash
curl http://localhost:11434/api/tags
```

Use the `name` (or `name` without `:latest`) in your IDE as the model ID.

## 🔄 Keeping Things Updated

- **Ollama (Docker image)**: Pull the latest image and recreate the container:
  ```bash
  docker-compose pull ollama
  docker-compose up -d ollama
  ```
- **Models**: The API supports pulling by tag (e.g. `llama3.2:latest`). To refresh a model to the latest version, pull again:
  ```bash
  curl -X POST http://localhost:11434/api/pull -d '{"model":"qwen3-coder:7b"}'
  ```
  Or from inside the container: `docker exec ollama-qwen3 ollama pull qwen3-coder:7b`. New tags and models appear in the [Ollama library](https://ollama.com/library); there is no separate “model API” — you use the same `/api/pull` with the model name.

## 📡 Ollama API & Model Library

Ollama exposes a REST API on port `11434`. Official docs: [Ollama API](https://ollama.com/docs/api).

| Action        | Method | Endpoint       | Example |
|---------------|--------|----------------|---------|
| List models   | GET    | `/api/tags`    | `curl http://localhost:11434/api/tags` |
| Pull model    | POST   | `/api/pull`    | `curl -X POST http://localhost:11434/api/pull -d '{"model":"llama3.2"}'` |
| Generate      | POST   | `/api/generate`| `curl -X POST http://localhost:11434/api/generate -d '{"model":"...","prompt":"..."}'` |
| Chat (OpenAI) | POST   | `/v1/chat/completions` | Use base URL `http://localhost:11434/v1` for OpenAI-compatible clients |

- **Model library**: [ollama.com/library](https://ollama.com/library) — browse and copy model names for `OLLAMA_MODEL` or `/api/pull`.
- **API reference**: [ollama.com/docs/api](https://ollama.com/docs/api) for full request/response formats.

## ⚙️ Environment Variables

All sensitive values live in `.env` (copy from `.env.example`). Do not commit `.env`.

### Ollama

- `OLLAMA_HOST`: Host to bind (default: `0.0.0.0`)
- `OLLAMA_MODEL`: Override auto-selected model (optional). Examples: `llama3.2`, `mistral`, `codellama`, `deepseek-coder`. Leave empty for hardware-based default.

### ngrok

- `NGROK_AUTHTOKEN`: ngrok authentication token (required for ngrok service)
- `NGROK_DOMAIN`: Optional reserved domain (e.g. `my-app.ngrok-free.dev`). Leave unset for a random URL.

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
