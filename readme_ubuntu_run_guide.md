# Offline AI Code Review Project — Ubuntu Native Setup Guide

## Overview
This guide explains exactly how to run the project on a **native Ubuntu system**. It includes:

- Which terminal to use
- Commands to run
- Expected output after each command
- First-time setup
- Daily usage
- Troubleshooting

---

# Prerequisites

You should already have the project folder copied onto Ubuntu:

```text
code-review-agent/
├── exports/
├── docker-compose.yml
├── load_and_run.sh
├── agent.py
├── jenkins_agent.py
├── Jenkinsfile
├── watched_code/
├── reports/
```

---

# Which Terminal to Use

Use the default **Ubuntu Terminal**.

Open using:

```text
Ctrl + Alt + T
```

All commands below are run in Ubuntu Terminal unless explicitly stated.

---

# STEP 1 — Install Docker (First Time Only)

## Run:

```bash
sudo apt update
sudo apt install docker.io docker-compose-plugin -y
```

## Expected Output:

```text
Reading package lists... Done
Building dependency tree... Done
Setting up docker.io ...
Setting up docker-compose-plugin ...
```

---

# STEP 2 — Start Docker Service

## Run:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

## Verify:

```bash
sudo systemctl status docker
```

## Expected Output:

```text
Active: active (running)
```

Press `q` to exit status view.

---

# STEP 3 — Allow Docker Without sudo

## Run:

```bash
sudo usermod -aG docker $USER
```

## Expected Output:

Usually no output.

## Important:
Logout and login again after this step.

---

# STEP 4 — Open Terminal Again After Login

Use:

```text
Ctrl + Alt + T
```

---

# STEP 5 — Go to Project Folder

## Example if project is in Home folder:

```bash
cd ~/code-review-agent
```

## Check files:

```bash
ls
```

## Expected Output:

```text
exports  docker-compose.yml  load_and_run.sh  watched_code  reports
```

---

# STEP 6 — Give Permission to Script

## Run:

```bash
chmod +x load_and_run.sh
```

## Expected Output:

No output.

---

# STEP 7 — Run Full Project

## Run:

```bash
./load_and_run.sh
```

## Expected Output:

```text
============================================
AI Code Review Agent - Load & Run
============================================
[1/6] Loading Ollama image...
Done.
[2/6] Loading Agent image...
Done.
[3/6] Loading Jenkins image...
Done.
[5/6] Starting all containers...
[6/6] Waiting for services...
Everything is running!
Jenkins : http://localhost:8080
Ollama  : http://localhost:11434
```

---

# STEP 8 — Verify Containers Running

## Run:

```bash
docker ps
```

## Expected Output:

```text
CONTAINER ID   IMAGE      STATUS
xxxxxxx        jenkins    Up
xxxxxxx        ollama     Up
xxxxxxx        agent      Up
```

You should see 3 running containers.

---

# STEP 9 — Open Jenkins in Browser

Use Firefox / Chrome on Ubuntu.

Open:

```text
http://localhost:8080
```

You should see Jenkins unlock screen.

---

# STEP 10 — Get Jenkins Initial Password

## In Ubuntu Terminal run:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## Expected Output:

```text
3d9e2c8ab4d54f6e9c...
```

Copy password and paste into browser.

---

# STEP 11 — Complete Jenkins Setup

In browser:

1. Paste password
2. Click Continue
3. Skip plugin install (already included)
4. Create admin user
5. Finish setup

---

# STEP 12 — Test AI Folder Watcher

## In Ubuntu Terminal run:

```bash
cp watched_code/sample_buggy_code.py watched_code/test.py
```

Wait 20–40 seconds.

---

# STEP 13 — Check Generated Reports

## Run:

```bash
ls reports
```

## Expected Output:

```text
20260428_153000_test.py.md
```

---

# STEP 14 — Open Report

## Run:

```bash
cat reports/20260428_153000_test.py.md
```

OR open graphically using Files app.

---

# Daily Usage

## Start Project

Run inside Ubuntu Terminal:

```bash
cd ~/code-review-agent
docker compose up -d
```

## Expected Output:

```text
Container jenkins Started
Container ollama Started
Container agent Started
```

---

## Stop Project

```bash
docker compose down
```

## Expected Output:

```text
Stopping jenkins ... done
Stopping ollama ... done
Stopping agent ... done
```

---

# Useful Commands

## See Live Logs

```bash
docker compose logs -f
```

## Restart Only Agent

```bash
docker compose restart agent
```

## Restart Jenkins

```bash
docker compose restart jenkins
```

## Check Docker Version

```bash
docker --version
```

---

# Troubleshooting

## 1. Permission Denied on Docker

Run:

```bash
newgrp docker
```

Then retry command.

---

## 2. load_and_run.sh Permission Denied

Run:

```bash
chmod +x load_and_run.sh
```

---

## 3. Jenkins Not Opening

Check containers:

```bash
docker ps
```

Check logs:

```bash
docker logs jenkins
```

---

## 4. Ollama Not Responding

Run:

```bash
docker logs ollama
```

Wait 30 seconds and retry.

---

## 5. Port 8080 Already in Use

Run:

```bash
sudo lsof -i :8080
```

Kill old process or change port in docker-compose.yml.

---

## 6. Port 11434 Already in Use

Run:

```bash
sudo lsof -i :11434
```

---

## 7. No Reports Generated

Check:

```bash
docker logs agent
```

Ensure file was copied into `watched_code/`.

---

# Final Quick Start

```bash
cd ~/code-review-agent
chmod +x load_and_run.sh
./load_and_run.sh
docker ps
```

Then open:

```text
http://localhost:8080
```

---

# Project Successfully Running When You See

- Jenkins opens in browser
- `docker ps` shows 3 containers Up
- Reports generated in `reports/`
- Ollama available on port 11434

