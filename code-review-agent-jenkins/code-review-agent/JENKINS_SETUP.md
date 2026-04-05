# Jenkins Setup Guide

Step-by-step instructions to connect this project to Jenkins.

---

## Step 1 — Install Jenkins on Windows

1. Download the Jenkins Windows installer from https://www.jenkins.io/download/
2. Run the installer — Jenkins will run as a Windows service on port 8080
3. Open your browser and go to: http://localhost:8080
4. Follow the setup wizard — install the "Suggested Plugins" when prompted

---

## Step 2 — Install required Jenkins plugins

Inside Jenkins go to:
**Manage Jenkins → Plugins → Available plugins**

Search and install:
- GitHub Integration Plugin
- Pipeline Plugin (usually pre-installed)
- Git Plugin (usually pre-installed)

---

## Step 3 — Make sure Ollama is running

Before any build runs, Ollama must be running in the background:

```
ollama serve
```

Keep this terminal open. Jenkins will connect to it at localhost:11434.

---

## Step 4 — Create a new Jenkins pipeline job

1. From the Jenkins dashboard click **New Item**
2. Enter a name: `ai-code-review-agent`
3. Select **Pipeline** and click OK
4. Under **Build Triggers** check: **GitHub hook trigger for GITScm polling**
5. Under **Pipeline** select: **Pipeline script from SCM**
6. Set SCM to **Git**
7. Enter your GitHub repo URL
8. Set branch to: `*/main` (or your branch name)
9. Set Script Path to: `Jenkinsfile`
10. Click **Save**

---

## Step 5 — Connect GitHub to Jenkins via webhook

1. Go to your GitHub repo
2. Click **Settings → Webhooks → Add webhook**
3. Set Payload URL to: `http://<your-machine-ip>:8080/github-webhook/`
4. Set Content type to: `application/json`
5. Select: **Just the push event**
6. Click **Add webhook**

> If Jenkins is on your local machine and not publicly accessible,
> use ngrok to expose it temporarily:
> `ngrok http 8080`
> Then use the ngrok URL as the webhook payload URL.

---

## Step 6 — Test it

1. Make sure `ollama serve` is running
2. Make sure Jenkins is running at http://localhost:8080
3. Push any `.py` file to your GitHub repo
4. Watch Jenkins automatically trigger a new build
5. Open the build → check **Console Output** for the review
6. Check the **Artifacts** tab for the generated markdown report

---

## File reference

| File | Purpose |
|------|---------|
| `Jenkinsfile` | Defines all pipeline stages |
| `jenkins_agent.py` | The AI review script called by Stage 4 |
| `agent.py` | Original folder-watcher agent (standalone use) |
| `requirements.txt` | Python dependencies |

---

## Exit code reference

| Code | Meaning | Jenkins result |
|------|---------|----------------|
| 0 | No critical issues | PASS (green) |
| 1 | Critical issues found | UNSTABLE (yellow) |
| 2 | Agent failed to run | FAILED (red) |
