# Complete Guide — Windows to Ubuntu Offline Transfer

Everything you need to build on Windows and run on Ubuntu offline.

---

## Overview

```
Windows laptop (internet)          Ubuntu office PC (no internet)
--------------------------         ------------------------------
1. Install Docker Desktop          1. Install Docker Engine only
2. Run build_and_export.bat        2. Copy USB contents to machine
3. Copy exports/ to USB            3. Run load_and_run.sh
                                   4. Open http://localhost:8080
```

---

## PART 1 — On your Windows laptop (needs internet)

### Step 1 — Install Docker Desktop

Download from docker.com/products/docker-desktop
Run the installer and restart your laptop when prompted.
Open Docker Desktop and wait until it shows "Docker Desktop is running."

### Step 2 — Open Command Prompt in the project folder

Extract this zip somewhere on your laptop.
Open Command Prompt and navigate to the folder:

```
cd C:\Users\Purushotham\Desktop\code-review-docker
```

### Step 3 — Create the exports folder

```
mkdir exports
```

### Step 4 — Run the build script

```
build_and_export.bat
```

This will:
- Build the Ollama + Mistral image (takes 10-15 min, downloads ~4GB)
- Build the Agent image (takes 2-3 min)
- Build the Jenkins image (takes 3-5 min)
- Export all three as .tar files into the exports/ folder

Go make a cup of tea — this takes a while the first time.

### Step 5 — Check the exports folder

You should now have:
```
exports/
├── ollama-mistral.tar   (~5GB)
├── agent.tar            (~200MB)
└── jenkins.tar          (~600MB)
```

### Step 6 — Copy everything to USB

Copy these onto your USB drive:
```
exports/                    (the three .tar files)
docker-compose.yml
load_and_run.sh
Jenkinsfile
jenkins_agent.py
agent.py
requirements.txt
watched_code/
```

---

## PART 2 — On your Ubuntu office PC (no internet needed)

### Step 1 — Install Docker Engine

This is the ONLY thing you need to install manually.
If you have internet temporarily, run:

```bash
sudo apt install docker.io docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Then log out and log back in.

If you have NO internet at all on Ubuntu, copy the Docker .deb
packages from the internet machine onto the USB as well:

On a machine with internet, run:
```bash
apt-get download docker.io docker-compose-plugin containerd
```
Copy the .deb files to USB, then on the offline Ubuntu machine:
```bash
sudo dpkg -i *.deb
```

### Step 2 — Copy USB contents to the machine

Plug in the USB and copy everything to your home folder:

```bash
cp -r /media/$USER/USB_DRIVE/code-review-docker ~/code-review-docker
cd ~/code-review-docker
```

### Step 3 — Make the script executable

```bash
chmod +x load_and_run.sh
```

### Step 4 — Run the load script

```bash
./load_and_run.sh
```

This will:
- Load all three Docker images from the .tar files
- Start all containers via docker-compose
- Wait for Ollama to be ready

### Step 5 — Verify everything is running

```bash
docker ps
```

You should see three containers running:
```
CONTAINER ID   IMAGE                    STATUS
xxxxxxxxxxxx   code-review-ollama       Up 2 minutes
xxxxxxxxxxxx   code-review-agent        Up 2 minutes
xxxxxxxxxxxx   code-review-jenkins      Up 2 minutes
```

---

## PART 3 — Using the standalone agent

Drop any code file into the watched_code/ folder:

```bash
cp watched_code/sample_buggy_code.py watched_code/test1.py
```

Wait 20-40 seconds. A report appears in reports/.

---

## PART 4 — Setting up Jenkins pipeline

### Step 1 — Open Jenkins

```
http://localhost:8080
```

Username: admin
Password: Run this to get it:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Step 2 — Create pipeline job

1. Click New Item
2. Name: ai-code-review
3. Select Pipeline → OK
4. Build Triggers → check GitHub hook trigger for GITScm polling
5. Pipeline → Definition → Pipeline script from SCM
6. SCM → Git → paste your repo URL
7. Branch → */main
8. Script Path → Jenkinsfile
9. Click Save

### Step 3 — Trigger a build manually (to test)

1. Click Build Now on the left sidebar
2. Click the build number that appears
3. Click Console Output to watch it run

---

## Stopping and starting everything

Stop all containers:
```bash
docker compose down
```

Start again:
```bash
docker compose up -d
```

View logs:
```bash
docker compose logs -f
```

---

## Folder structure

```
code-review-docker/
├── Dockerfile.ollama          # Ollama + Mistral image
├── Dockerfile.agent           # Python agent image
├── Dockerfile.jenkins         # Jenkins image
├── docker-compose.yml         # Runs all three together
├── build_and_export.bat       # Run on Windows to build
├── load_and_run.sh            # Run on Ubuntu to load
├── Jenkinsfile                # Pipeline definition
├── jenkins_agent.py           # AI review script for Jenkins
├── agent.py                   # Standalone folder watcher
├── requirements.txt           # Python dependencies
├── watched_code/              # Drop files here to trigger review
│   └── sample_buggy_code.py   # Test file with bugs
├── reports/                   # Generated reports saved here
└── exports/                   # .tar image files for USB transfer
```

---

## USB drive size needed

| Item | Size |
|------|------|
| Ollama + Mistral image | ~5 GB |
| Agent image | ~200 MB |
| Jenkins image | ~600 MB |
| Project files | ~5 MB |
| Total | ~6 GB |

Use at least a 8GB USB drive.

---

*Offline AI Code Review Agent — Docker Edition*
*Uses Mistral by Mistral AI via Ollama. No cloud. No API keys.*
