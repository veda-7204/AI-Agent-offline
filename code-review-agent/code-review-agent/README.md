# Offline AI Code Review Agent

An autonomous AI agent that monitors a local folder for code changes and automatically generates a detailed review report — entirely offline, with no cloud APIs or subscriptions required.

---

## What It Does

Whenever a code file is added or modified in the `watched_code/` folder, the agent:

1. **Detects the change** — identifies the file and what triggered the event
2. **Reads the code** — extracts the full content for analysis
3. **Sends it to a local LLM** — uses CodeLlama running via Ollama on your machine
4. **Gets back a full review** including:
   - Summary of what the code does
   - Suggestions for improvement
   - Errors and bugs detected
   - An overall quality rating
5. **Saves a markdown report** — timestamped and stored in the `reports/` folder

Everything runs on your local machine. No internet needed after setup.

---

## Architecture

```
New/modified file in watched_code/
        |
        v
  File Watcher (watchdog)
        |
        v
  Code Reader + Hash Check
        |
        v
  Local LLM via Ollama (CodeLlama)
        |
        v
  Markdown Report saved to reports/
```

---

## Tech Stack

| Component       | Tool              | Purpose                          |
|----------------|-------------------|----------------------------------|
| File watching  | watchdog          | Detect new/changed files         |
| LLM runner     | Ollama            | Run AI models locally            |
| AI model       | CodeLlama (Meta)  | Understand and review code       |
| Report output  | Markdown          | Human-readable review files      |
| Language       | Python 3.8+       | Glue for the whole pipeline      |

---

## Setup Instructions

### Step 1 — Install Ollama

Download and install from: https://ollama.ai

Then open a terminal and pull the CodeLlama model:

```bash
ollama pull codellama
```

This downloads the model (~4GB). Only needs to be done once.

### Step 2 — Clone this repo

```bash
git clone <your-repo-url>
cd code-review-agent
```

### Step 3 — Install Python dependencies

```bash
pip install -r requirements.txt
```

### Step 4 — Start Ollama

In a separate terminal window, run:

```bash
ollama serve
```

Keep this running in the background.

### Step 5 — Run the agent

```bash
python agent.py
```

You should see:

```
============================================================
   Offline AI Code Review Agent
   Model : CodeLlama (via Ollama)
   Watching: C:\...\watched_code
============================================================

  Drop any code file into the 'watched_code' folder
  and the agent will automatically review it.

  Press Ctrl+C to stop.
```

---

## Usage

1. Make sure the agent is running (`python agent.py`)
2. Drop any `.py`, `.js`, `.ts`, `.java`, `.cpp`, `.go` file into the `watched_code/` folder
3. The agent detects it instantly and sends it for analysis
4. A preview of the review appears in the terminal
5. The full report is saved in the `reports/` folder as a `.md` file

### Example report output

```markdown
# Code Review Report

**File:** `sample_buggy_code.py`
**Event:** Created
**Date:** 2025-01-15 14:32:08
**Lines of code:** 18

## AI Analysis

1. SUMMARY OF CHANGES
   This file contains utility functions for discounts and user lookup...

2. SUGGESTIONS
   - Use .get() instead of direct dict access to avoid KeyError
   - Add input validation for negative prices...

3. ERRORS & BUGS DETECTED
   - Line 14: Index out of range — loop goes to len(items)+1
   - Line 17: ZeroDivisionError possible when b=0
   - Line 12: KeyError when user_id not in dict

4. OVERALL RATING
   4/10 — Functional logic but contains multiple unhandled exceptions.
```

---

## Folder Structure

```
code-review-agent/
├── agent.py                  # Main agent script
├── requirements.txt          # Python dependencies
├── README.md                 # This file
├── watched_code/             # Drop code files here
│   └── sample_buggy_code.py  # Example file to test with
└── reports/                  # Generated reports saved here
```

---

## Supported File Types

`.py` `.js` `.ts` `.java` `.cpp` `.c` `.go` `.rb` `.php`

---

## Future Improvements (Roadmap)

- [ ] GitHub webhook trigger instead of folder watching
- [ ] Docker sandbox to safely execute the code and capture output
- [ ] HTML report with syntax highlighting
- [ ] Slack / email notification when a report is generated
- [ ] Support for reviewing git diffs instead of full files
- [ ] Web dashboard to browse all past reports

---

## Requirements

- Python 3.8+
- Ollama installed and running
- 8GB+ RAM recommended for CodeLlama 7B
- Git, Docker (for future roadmap features)

---

*Built as an offline AI agent project. Uses Meta's CodeLlama model via Ollama — no cloud APIs, no subscriptions, no internet required during operation.*
