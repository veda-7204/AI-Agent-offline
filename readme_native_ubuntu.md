# Offline AI Code Review Project — Build & Run on Native Ubuntu

## Overview
This guide is for running the project on a **native Ubuntu system** using the source files you shared.

Your `docker-compose.yml` uses prebuilt images, so we first build the Docker images manually, then start the containers.

This README includes:

- Exact commands
- Which terminal to use
- Expected outputs
- Jenkins setup
- Testing the AI agent
- Troubleshooting

---

# Project Files Required

```text
code-review-agent/
├── docker-compose.yml
├── Dockerfile.agent
├── Dockerfile.jenkins
├── Dockerfile.ollama
├── agent.py
├── jenkins_agent.py
├── Jenkinsfile
├── requirements.txt
├── watched_code/
├── reports/
```

---

# Which Terminal to Use

Use the default **Ubuntu Terminal**.

Open with:

```text
Ctrl + Alt + T
```

All commands below are run in Ubuntu Terminal.

---

# STEP 1 — Go to Project Folder

## Example:

```bash
cd ~/code-review-agent
```

## Verify Files:

```bash
ls
```

## Expected Output:

```text
docker-compose.yml
Dockerfile.agent
Dockerfile.jenkins
Dockerfile.ollama
agent.py
```

---

# STEP 2 — Install Docker (First Time Only)

## Run:

```bash
sudo apt update
sudo apt install docker.io docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker
```

## Expected Output:

```text
Setting up docker.io ...
Setting up docker-compose-plugin ...
```

---

# STEP 3 — Build Docker Images Manually

Your compose file expects these images:

- `code-review-ollama:latest`
- `code-review-agent:latest`
- `code-review-jenkins:latest`

So build them first.

---

## 3.1 Build Ollama Image

```bash
docker build -f Dockerfile.ollama -t code-review-ollama:latest .
```

## Expected Output:

```text
Successfully tagged code-review-ollama:latest
```

Note: This may take the longest because it downloads the model.

---

## 3.2 Build Agent Image

```bash
docker build -f Dockerfile.agent -t code-review-agent:latest .
```

## Expected Output:

```text
Successfully tagged code-review-agent:latest
```

---

## 3.3 Build Jenkins Image

```bash
docker build -f Dockerfile.jenkins -t code-review-jenkins:latest .
```

## Expected Output:

```text
Successfully tagged code-review-jenkins:latest
```

---

# STEP 4 — Start All Containers

## Run:

```bash
docker compose up -d
```

## Expected Output:

```text
Creating ollama ... done
Creating agent ... done
Creating jenkins ... done
```

---

# STEP 5 — Verify Running Containers

## Run:

```bash
docker ps
```

## Expected Output:

```text
CONTAINER ID   IMAGE                       STATUS
xxxxxxx        code-review-ollama         Up (healthy)
xxxxxxx        code-review-agent          Up
xxxxxxx        code-review-jenkins        Up
```

---

# STEP 6 — Open Jenkins in Browser

Open Firefox / Chrome on Ubuntu:

```text
http://localhost:8080
```

You should see Jenkins unlock screen.

---

# STEP 7 — Get Jenkins Password

## Run in Ubuntu Terminal:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## Expected Output:

```text
3d9e2c8ab4d54f6e9c...
```

Copy and paste into Jenkins browser.

---

# STEP 8 — Complete Jenkins Setup

In browser:

1. Paste password
2. Continue
3. Skip plugin installation (already installed)
4. Create admin user
5. Finish setup

---

# STEP 9 — Test Folder Watcher Agent

## Run:

```bash
cp watched_code/sample_buggy_code.py watched_code/test.py
```

Wait 20–40 seconds.

---

# STEP 10 — Check Reports

## Run:

```bash
ls reports
```

## Expected Output:

```text
20260428_153000_test.py.md
```

---

# STEP 11 — Open Report

## Run:

```bash
cat reports/20260428_153000_test.py.md
```

OR open via Files app.

---

# Daily Usage

## Start Project Again Later

```bash
cd ~/code-review-agent
docker compose up -d
```

---

## Stop Project

```bash
docker compose down
```

---

# Useful Commands

## See Live Logs

```bash
docker compose logs -f
```

## Logs for Ollama Only

```bash
docker logs ollama
```

## Logs for Jenkins Only

```bash
docker logs jenkins
```

## Restart Agent

```bash
docker compose restart agent
```

---

# Troubleshooting

## 1. Docker Permission Denied

Run:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 2. Jenkins Not Opening

Check:

```bash
docker ps
```

Then:

```bash
docker logs jenkins
```

---

## 3. Ollama Still Starting

Run:

```bash
docker logs ollama
```

Wait a little longer.

---

## 4. Build Failed While Pulling Model

Check internet connection and retry:

```bash
docker build -f Dockerfile.ollama -t code-review-ollama:latest .
```

---

## 5. Port 8080 Already In Use

```bash
sudo lsof -i :8080
```

Stop conflicting service.

---

## 6. Port 11434 Already In Use

```bash
sudo lsof -i :11434
```

---

## 7. No Reports Generated

Check agent logs:

```bash
docker logs agent
```

Ensure file was copied into `watched_code/`.

---

# Final Quick Start (Copy/Paste)

```bash
cd ~/code-review-agent
sudo apt update
sudo apt install docker.io docker-compose-plugin -y
sudo systemctl start docker

docker build -f Dockerfile.ollama -t code-review-ollama:latest .
docker build -f Dockerfile.agent -t code-review-agent:latest .
docker build -f Dockerfile.jenkins -t code-review-jenkins:latest .

docker compose up -d
docker ps
```

Then open:

```text
http://localhost:8080
```

---

# Project Is Successfully Running When

- Jenkins opens in browser
- `docker ps` shows 3 containers Up
- Reports appear in `reports/`
- Ollama responds on port 11434

