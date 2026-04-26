# Complete Docker Setup Guide
## Windows laptop → Ubuntu office PC (fully offline)

---

## What this setup gives you

One USB drive containing everything needed to run the full
AI code review agent on any Ubuntu machine with zero internet.

No Java installation. No Python installation. No Ollama installation.
No pip. Nothing manual. Just Docker — and one command.

---

## What's in the USB (after running build_and_export.bat)

```
docker-exports/
├── ollama-image.tar          # Ollama + CodeLlama (~5GB)
├── agent-image.tar           # Python + agent code (~200MB)
├── jenkins-image.tar         # Jenkins + Java + plugins (~800MB)
├── docker-compose.yml        # Starts all three containers
├── agent.py                  # Agent source code
├── jenkins_agent.py          # Jenkins agent source code
├── Jenkinsfile               # Jenkins pipeline definition
├── requirements.txt          # Python dependencies
├── watched_code/
│   └── sample_buggy_code.py  # Test file with bugs
└── reports/                  # Reports appear here
```

---

## PART 1 — On your Windows laptop (needs internet, done once)

---

### 1.1 — Install Docker Desktop for Windows

Download from: https://www.docker.com/products/docker-desktop/
Run the installer. Restart your laptop when prompted.
Open Docker Desktop and wait until it says "Docker Desktop is running".

---

### 1.2 — Get the project folder ready

Extract the project zip. You should have this structure:

```
code-review-docker/
├── ollama/
│   ├── Dockerfile.ollama
│   └── pull_model.sh
├── agent/
│   └── Dockerfile.agent
├── jenkins/
│   ├── Dockerfile.jenkins
│   └── plugins.txt
├── agent.py
├── jenkins_agent.py
├── Jenkinsfile
├── requirements.txt
├── docker-compose.yml
├── build_and_export.bat      ← run this
└── watched_code/
    └── sample_buggy_code.py
```

---

### 1.3 — Run the build script

Open Command Prompt in the project folder and run:

```
build_and_export.bat
```

This will:
- Build the Ollama image and download CodeLlama (~4GB) — takes 10-15 mins
- Build the agent image — takes 2 mins
- Build the Jenkins image — takes 5 mins
- Export all three as .tar files into a docker-exports/ folder

Go get a coffee — this takes around 20 minutes total.

When it finishes you'll see:
```
BUILD COMPLETE
Copy the entire docker-exports\ folder to USB
```

---

### 1.4 — Copy to USB

Plug in your USB drive (needs at least 8GB free).
Copy the entire `docker-exports/` folder to the USB.

---

## PART 2 — On your Ubuntu office PC (no internet needed)

---

### 2.1 — Install Docker on Ubuntu

This is the ONLY thing you install manually on the office PC.

If you have even temporary internet:
```bash
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```
Log out and log back in after this.

If you have NO internet at all:
Download the Docker .deb packages on another machine and copy
them to USB too. Then install with:
```bash
sudo dpkg -i docker.io_*.deb
sudo dpkg -i docker-compose_*.deb
```

---

### 2.2 — Copy files from USB to the PC

Plug in USB. Copy the entire docker-exports/ folder to your home directory:

```bash
cp -r /media/$USER/USB/docker-exports ~/code-review-agent
cd ~/code-review-agent
```

---

### 2.3 — Make the load script executable

```bash
chmod +x load_and_run.sh
```

---

### 2.4 — Run the load script

```bash
./load_and_run.sh
```

This will:
- Load all three Docker images from the .tar files
- Create the watched_code/ and reports/ folders
- Start all three containers automatically

When it finishes you'll see:
```
=====================================================
  ALL CONTAINERS STARTED

  Jenkins  : http://localhost:8080
  Ollama   : http://localhost:11434

  Drop code files into: watched_code/
  Reports appear in  : reports/
=====================================================
```

---

### 2.5 — Set up Jenkins pipeline (one time only)

Open browser → http://localhost:8080

Get the Jenkins unlock password:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Paste it in the browser → click Skip plugin install (already pre-installed)
→ Create admin account → Save.

Now create the pipeline:
1. Click New Item
2. Name: ai-code-review
3. Select Pipeline → OK
4. Under Pipeline → Definition → select Pipeline script
5. Open Jenkinsfile from your project folder in a text editor
6. Copy all the text → paste into the Jenkins text box
7. Click Save

---

### 2.6 — Test it

Drop the sample file into watched_code/:

```bash
cp watched_code/sample_buggy_code.py watched_code/test1.py
```

In Jenkins, go to your pipeline → click Build Now.

Watch it run → check the Artifacts tab for the report.

---

## Daily usage (after setup)

Every day when you come to the office:

```bash
cd ~/code-review-agent
docker-compose up -d
```

That's it. All three containers start. Everything is running.

To stop at end of day:
```bash
docker-compose down
```

---

## Useful commands

| Command | What it does |
|---------|-------------|
| `docker-compose up -d` | Start everything in background |
| `docker-compose down` | Stop everything |
| `docker-compose logs -f` | Watch live logs from all containers |
| `docker-compose logs ollama` | Logs from Ollama only |
| `docker-compose logs jenkins` | Logs from Jenkins only |
| `docker ps` | See which containers are running |
| `docker-compose restart agent` | Restart just the agent |

---

## Troubleshooting

**Jenkins won't start**
```bash
docker-compose logs jenkins
```
Look for the error message and share it.

**Ollama not responding**
```bash
docker-compose logs ollama
```
Ollama takes 10-20 seconds to fully start. Wait and try again.

**Agent not detecting files**
Make sure you're dropping files into the watched_code/ folder
in the same directory as docker-compose.yml.

**Permission denied on docker commands**
```bash
sudo usermod -aG docker $USER
```
Then log out and back in.

---

## Architecture summary

```
Your Ubuntu PC
│
├── Docker Container 1: Jenkins (port 8080)
│     └── Calls jenkins_agent.py on code push
│
├── Docker Container 2: Agent
│     └── Watches watched_code/ folder
│         Sends code to Ollama for review
│
└── Docker Container 3: Ollama (port 11434)
      └── Runs CodeLlama model
          Returns AI analysis
          100% offline
```

All three containers talk to each other internally.
Nothing leaves your machine.

---

*Offline AI Code Review Agent — Full Docker Setup*
*Windows build → Ubuntu deployment*
