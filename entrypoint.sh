#!/bin/bash
# Detecta hardware & auto-config
nvidia-smi &> /dev/null && GPU="nvidia" || GPU="cpu"
VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n1 || echo 0)
RAM=$(free -g | awk 'NR==2{print $2}')
echo "Detected: GPU=$GPU, VRAM=${VRAM}GB, RAM=${RAM}GB"

# Auto-model by hardware
if [ $VRAM -ge 16 ]; then MODEL="qwen3-coder:30b:Q4_K_M"; fi 
elif [ $VRAM -ge 8 ]; then MODEL="qwen3-coder:30b:IQ3_M"; fi 
else MODEL="qwen3-coder:7b:Q4_0"; fi  

ollama serve &
sleep 10
ollama pull $MODEL
echo "Model loaded: $MODEL. Ready on :11434"
wait
