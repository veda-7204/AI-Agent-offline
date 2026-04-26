#!/bin/bash
# load_and_run.sh
# ---------------
# Run this on your Ubuntu office PC (completely offline).
# Loads Docker images from USB and starts everything.

echo "============================================"
echo "  AI Code Review Agent - Load & Run"
echo "  Run this on Ubuntu (no internet needed)"
echo "============================================"
echo ""

# Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed."
    echo "Install it with: sudo apt install docker.io -y"
    exit 1
fi

# Check docker-compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "Installing docker-compose plugin..."
    sudo apt install docker-compose-plugin -y
fi

echo "[1/6] Loading Ollama + Mistral image from tar..."
echo "This may take a few minutes..."
docker load < exports/ollama-mistral.tar
echo "Done."
echo ""

echo "[2/6] Loading Agent image from tar..."
docker load < exports/agent.tar
echo "Done."
echo ""

echo "[3/6] Loading Jenkins image from tar..."
docker load < exports/jenkins.tar
echo "Done."
echo ""

echo "[4/6] Creating required folders..."
mkdir -p watched_code reports
echo "Done."
echo ""

echo "[5/6] Starting all containers..."
docker compose up -d
echo ""

echo "[6/6] Waiting for services to be ready..."
echo "Waiting for Ollama to load Mistral (30 seconds)..."
sleep 30

# Check if Ollama is responding
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "Ollama is running."
else
    echo "Ollama is still starting up. Give it another 30 seconds."
fi

echo ""
echo "============================================"
echo "  Everything is running!"
echo ""
echo "  Jenkins  : http://localhost:8080"
echo "  Ollama   : http://localhost:11434"
echo ""
echo "  To use the folder watcher agent:"
echo "  Drop any code file into watched_code/"
echo "  Report will appear in reports/"
echo ""
echo "  To use Jenkins pipeline:"
echo "  Open http://localhost:8080"
echo "  Create a pipeline job pointing to your repo"
echo ""
echo "  To stop everything:"
echo "  docker compose down"
echo "============================================"
