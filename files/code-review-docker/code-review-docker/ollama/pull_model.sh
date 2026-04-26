#!/bin/bash
# pull_model.sh
# Runs during Docker build to bake CodeLlama into the image.

# Start Ollama server in background
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "Waiting for Ollama to start..."
sleep 5

# Pull CodeLlama model
echo "Pulling CodeLlama model (this takes a few minutes)..."
ollama pull codellama

# Stop the background Ollama server
kill $OLLAMA_PID

echo "CodeLlama model baked into image successfully."
