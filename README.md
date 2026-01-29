# Ollama Coding

Ollama en Docker con **Qwen 3 Coder** para uso local. Integración con VS Code u otro editor vía API local.

## Requisitos

- Docker y Docker Compose
- NVIDIA Docker Runtime (`nvidia-docker2`) si quieres usar GPU

## Uso rápido

1. Copia `.env.example` a `.env` (opcional; solo si quieres cambiar modelo u opciones).
2. Levanta el servicio:

```bash
docker-compose up -d
```

3. El modelo se descarga al arrancar según la VRAM detectada (solo variantes Qwen 3 Coder).

## Modelos (Qwen 3 Coder)

El `entrypoint.sh` elige una variante según VRAM:

| VRAM     | Modelo por defecto              |
|----------|----------------------------------|
| ≥ 32 GB  | `qwen3-coder:30b-a3b-q8_0`       |
| ≥ 20 GB  | `qwen3-coder:30b-a3b-q4_K_M`     |
| < 20 GB  | `qwen3-coder:30b-a3b-q4_K_M` (con offload a CPU/RAM) |

Para forzar un modelo, define `OLLAMA_MODEL` en `.env`, por ejemplo:

- `qwen3-coder:30b-a3b-q4_K_M` (~19 GB)
- `qwen3-coder:30b-a3b-q8_0` (~32 GB)
- `qwen3-coder:30b-a3b-fp16` (~61 GB)

## Integración con VS Code

1. **URL base**: `http://localhost:11434/v1`
2. **Modelo**: el que tengas cargado (p. ej. `qwen3-coder:30b-a3b-q4_K_M`)
3. **API Key**: `ollama` (o la que use tu extensión para Ollama local)

Configura la extensión de Ollama o la de OpenAI-compatible en VS Code apuntando a esa URL y modelo.

## Estructura

```
ollama-coding/
├── .env                  # Tus variables (crear desde .env.example, no commitear)
├── .env.example          # Plantilla de variables
├── docker-compose.yml    # NVIDIA GPU
├── docker-compose.amd.yml # Opcional: AMD GPU (ROCm)
├── entrypoint.sh         # Inicio + detección de VRAM y pull del modelo
└── README.md
```

## Variables de entorno

- `OLLAMA_HOST`: interfaz (por defecto `0.0.0.0`)
- `OLLAMA_MODEL`: modelo fijo (vacío = auto según VRAM)
- `CUDA_VISIBLE_DEVICES`: GPUs a usar (vacío = todas)
- `OLLAMA_NUM_PARALLEL`: peticiones en paralelo (opcional)
- `OLLAMA_VULKAN`: `1` para Intel/AMD (opcional)

## GPU AMD

Si usas AMD en lugar de NVIDIA:

```bash
docker compose -f docker-compose.amd.yml up -d
```

Define `OLLAMA_MODEL` en `.env` (la detección automática de VRAM en el entrypoint es solo para NVIDIA).
