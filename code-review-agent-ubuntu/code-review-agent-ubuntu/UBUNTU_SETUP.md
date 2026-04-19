# Complete Setup & Run Guide — Ubuntu

This guide takes you from a fresh Ubuntu machine to a fully running
offline AI code review agent with Jenkins CI/CD pipeline.

---

## What you need before starting

- Ubuntu 20.04 or 22.04
- At least 8GB RAM (for CodeLlama 7B model)
- At least 10GB free disk space
- Python 3 installed (comes with Ubuntu by default)
- Git installed
- Docker installed
- Internet access ONLY for the initial setup steps below
  (after setup everything runs offline)

---

## PART 1 — Install everything (one time only)

---

### 1.1 — Update your system

Open a terminal and run:

```bash
sudo apt update && sudo apt upgrade -y
```

---

### 1.2 — Install Python pip and curl (if not already there)

```bash
sudo apt install python3-pip curl -y
```

---

### 1.3 — Install Docker

```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

Add your user to the docker group so you don't need sudo every time:

```bash
sudo usermod -aG docker $USER
```

Then log out and log back in for this to take effect. Verify Docker works:

```bash
docker run hello-world
```

You should see "Hello from Docker!" — that means it's working.

---

### 1.4 — Install Ollama

```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

Verify Ollama installed correctly:

```bash
ollama --version
```

---

### 1.5 — Pull the CodeLlama model

This downloads the AI model (~4GB). Only do this once.

```bash
ollama pull codellama
```

Wait for it to finish. You'll see a progress bar.

---

### 1.6 — Install Jenkins

Jenkins requires Java. Install it first:

```bash
sudo apt install fontconfig openjdk-17-jre -y
```

Verify Java works:

```bash
java -version
```

Now add the Jenkins repository and install it:

```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y
```

Start Jenkins and enable it to auto-start on boot:

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

Check Jenkins is running:

```bash
sudo systemctl status jenkins
```

You should see "active (running)" in green.

---

### 1.7 — Open Jenkins in the browser

```
http://localhost:8080
```

Get the initial unlock password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password, paste it into the browser, then:
- Click "Install Suggested Plugins" — wait for it to finish
- Create your admin username and password
- Click "Save and Finish"

---

### 1.8 — Install the GitHub plugin in Jenkins

Inside Jenkins go to:

    Manage Jenkins → Plugins → Available plugins

Search for: **GitHub Integration Plugin**

Check the box → click **Install** → wait → restart Jenkins.

---

### 1.9 — Allow Jenkins to run Docker and Python

By default Jenkins runs as its own user and may not have permission
to run Docker or Python. Fix this:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Also make sure Python3 is accessible from Jenkins:

```bash
which python3
```

Note the path (usually /usr/bin/python3) — you may need it later.

---

## PART 2 — Set up the project

---

### 2.1 — Get the project files onto the machine

If you have internet:
```bash
git clone <your-github-repo-url>
cd code-review-agent-ubuntu
```

If you are completely offline (no internet at all):
Copy the project folder onto the machine via USB drive, then:
```bash
cd /path/to/code-review-agent-ubuntu
```

---

### 2.2 — Install Python dependencies

```bash
pip3 install -r requirements.txt
```

---

### 2.3 — Push the project to GitHub (needed for Jenkins)

If not already on GitHub:

```bash
git init
git add .
git commit -m "initial commit: offline AI code review agent"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

---

## PART 3 — Create the Jenkins pipeline

---

### 3.1 — Create a new pipeline job

1. Open Jenkins at http://localhost:8080
2. Click **New Item** on the left sidebar
3. Enter name: `ai-code-review`
4. Select **Pipeline**
5. Click **OK**

---

### 3.2 — Configure the pipeline

On the configuration page:

**Under "General":**
- Check: **GitHub project**
- Project URL: paste your GitHub repo URL

**Under "Build Triggers":**
- Check: **GitHub hook trigger for GITScm polling**

**Under "Pipeline":**
- Definition: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: paste your GitHub repo URL
- Branch Specifier: `*/main`
- Script Path: `Jenkinsfile`

Click **Save**.

---

### 3.3 — Connect GitHub to Jenkins (webhook)

For GitHub to automatically notify Jenkins on every push,
Jenkins needs a public URL. 

**Option A — If Jenkins is on a server with a public IP:**

Your webhook URL is simply:
```
http://<your-server-ip>:8080/github-webhook/
```

Go to your GitHub repo:
Settings → Webhooks → Add webhook
- Payload URL: `http://<your-server-ip>:8080/github-webhook/`
- Content type: `application/json`
- Event: **Just the push event**
- Click **Add webhook**

**Option B — If Jenkins is on a local machine (no public IP):**

Install ngrok:
```bash
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
  sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
  sudo tee /etc/apt/sources.list.d/ngrok.list && \
  sudo apt update && sudo apt install ngrok

ngrok config add-authtoken <your-ngrok-token>
ngrok http 8080
```

Copy the https URL ngrok gives you (e.g. https://abc123.ngrok.io)

Then set the GitHub webhook to:
```
https://abc123.ngrok.io/github-webhook/
```

---

## PART 4 — Run it

---

### 4.1 — Start Ollama (keep this running)

Open Terminal 1:

```bash
ollama serve
```

You should see:
```
Listening on 127.0.0.1:11434
```

Leave this terminal open the entire time.

---

### 4.2 — Trigger the pipeline

Make any code change and push to GitHub:

```bash
git add .
git commit -m "test: trigger AI review pipeline"
git push
```

---

### 4.3 — Watch it run in Jenkins

1. Open http://localhost:8080
2. Click your `ai-code-review` job
3. You will see a new build appear automatically
4. Click the build number (e.g. #1)
5. Click **Console Output** to watch it run live

You will see each stage running:
```
[Checkout] Checking out commit...
[Setup] Installing Python dependencies...
[Detect Changes] Changed files: sample_buggy_code.py
[AI Review] Reviewing: sample_buggy_code.py
[AI Review] Sending to CodeLlama...
[AI Review] Result: CRITICAL ISSUES FOUND
[Run Code (Sandbox)] Running in Docker...
[Publish Report] Report saved: reports/20250406_...md
BUILD UNSTABLE
```

---

### 4.4 — Get the report

When the build finishes:
1. Click the **Artifacts** tab inside the build
2. Click the `.md` report file to view it
3. It shows the full AI analysis — errors, suggestions, rating

---

## PART 5 — Run the standalone agent (no Jenkins)

If you just want to test the AI review without Jenkins:

**Terminal 1 — start Ollama:**
```bash
ollama serve
```

**Terminal 2 — start the agent:**
```bash
cd code-review-agent-ubuntu
python3 agent.py
```

**Trigger it — drop a file into watched_code/:**
```bash
cp watched_code/sample_buggy_code.py watched_code/test1.py
```

The agent detects it instantly. After 20–40 seconds a report
appears in the reports/ folder.

Stop the agent:
```bash
Ctrl + C
```

---

## Troubleshooting

**"Cannot connect to Ollama"**
Ollama is not running. Run: `ollama serve`

**Jenkins shows "Permission denied" for Docker**
Run: `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins`

**Jenkins shows "python3 not found"**
Run: `which python3` to find the path, then in the Jenkinsfile
replace `python3` with the full path e.g. `/usr/bin/python3`

**Build not triggering automatically**
The webhook is not connected. Follow Part 3.3 above.
Also check: Manage Jenkins → System Log for webhook errors.

**Ollama is slow on first run**
Normal — the first review takes 30–60 seconds as the model loads
into memory. Subsequent reviews are faster.

**"ollama: command not found" after install**
Run: `source ~/.bashrc` or open a new terminal.

---

## Folder structure

```
code-review-agent-ubuntu/
├── Jenkinsfile                   # Pipeline definition (Ubuntu/Linux)
├── jenkins_agent.py              # AI review script called by Jenkins
├── agent.py                      # Standalone folder-watcher agent
├── requirements.txt              # Python dependencies
├── .gitignore                    # Git ignore rules
├── UBUNTU_SETUP.md               # This file
├── watched_code/
│   └── sample_buggy_code.py      # Test file with intentional bugs
└── reports/                      # Generated reports saved here
```

---

## What stays running during operation

| Service     | Command          | Terminal |
|-------------|------------------|----------|
| Ollama      | `ollama serve`   | Keep open |
| Jenkins     | Auto (service)   | Browser only |
| Docker      | Auto (service)   | Nothing needed |
| ngrok       | `ngrok http 8080`| Keep open (if local) |

---

*Offline AI Code Review Agent — Ubuntu version*
*Uses CodeLlama by Meta via Ollama. No cloud. No API keys.*
