#!/bin/bash
# Hardware detection and auto-config. VRAM from nvidia-smi is in MB. Multi-GPU: total VRAM is summed.
nvidia-smi &> /dev/null && GPU="nvidia" || GPU="cpu"
VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
GPU_COUNT=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | wc -l)
RAM=$(free -g | awk 'NR==2{print $2}')
VRAM_GB=$((VRAM_MB / 1024))
echo "Detected: GPU=$GPU (${GPU_COUNT} device(s)), total VRAM=${VRAM_GB}GB (${VRAM_MB}MB), RAM=${RAM}GB"

# Auto-select model by VRAM (override with OLLAMA_MODEL). Prefer qwen3-coder (v3) when VRAM allows; no 7b in v3, so use qwen2.5-coder for 8GB and below.
if [ -n "$OLLAMA_MODEL" ]; then
  MODEL="$OLLAMA_MODEL"
elif [ "$VRAM_MB" -ge 16384 ]; then
  MODEL="qwen3-coder:30b-a3b-q4_K_M"
elif [ "$VRAM_MB" -ge 8192 ]; then
  MODEL="qwen2.5-coder:7b"
else
  MODEL="qwen2.5-coder:3b"
fi

ollama serve &
sleep 10
ollama pull $MODEL
echo "Model loaded: $MODEL. Ready on :11434"
wait
