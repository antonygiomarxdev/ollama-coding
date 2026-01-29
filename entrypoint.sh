#!/bin/bash
# Detección de hardware y auto-config. VRAM en MB (nvidia-smi). Multi-GPU: se suma la VRAM total.
nvidia-smi &> /dev/null && GPU="nvidia" || GPU="cpu"
VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
GPU_COUNT=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | wc -l)
RAM=$(free -g | awk 'NR==2{print $2}')
VRAM_GB=$((VRAM_MB / 1024))
echo "Detected: GPU=$GPU (${GPU_COUNT} device(s)), total VRAM=${VRAM_GB}GB (${VRAM_MB}MB), RAM=${RAM}GB"

# Modelo por defecto: Qwen 3 Coder. Variantes: 30b-a3b-q4_K_M (~19GB), 30b-a3b-q8_0 (~32GB), 30b-a3b-fp16 (~61GB).
if [ -n "$OLLAMA_MODEL" ]; then
  MODEL="$OLLAMA_MODEL"
elif [ "$VRAM_MB" -ge 32768 ]; then
  MODEL="qwen3-coder:30b-a3b-q8_0"
elif [ "$VRAM_MB" -ge 20480 ]; then
  MODEL="qwen3-coder:30b-a3b-q4_K_M"
else
  # < 20GB VRAM: mismo modelo, Ollama usará CPU/RAM para el resto
  MODEL="qwen3-coder:30b-a3b-q4_K_M"
fi

ollama serve &
sleep 10
ollama pull $MODEL
echo "Model loaded: $MODEL. Ready on :11434"
wait
