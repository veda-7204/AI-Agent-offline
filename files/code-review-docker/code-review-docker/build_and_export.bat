@echo off
REM build_and_export.bat
REM --------------------
REM Run this on your Windows laptop (needs internet).
REM Builds all three Docker images and exports them as .tar files
REM ready to copy to a USB drive.

echo ============================================
echo   AI Code Review Agent - Docker Builder
echo   Run this on Windows (needs internet)
echo ============================================
echo.

REM Check Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker Desktop is not running.
    echo Please open Docker Desktop and wait for it to start.
    pause
    exit /b 1
)

echo [1/6] Building Ollama + Mistral image...
echo This will take 10-15 minutes as it downloads Mistral (~4GB)
echo Please be patient...
docker build -f Dockerfile.ollama -t code-review-ollama:latest .
if errorlevel 1 (
    echo ERROR: Failed to build Ollama image.
    pause
    exit /b 1
)
echo Ollama image built successfully.
echo.

echo [2/6] Building Agent image...
docker build -f Dockerfile.agent -t code-review-agent:latest .
if errorlevel 1 (
    echo ERROR: Failed to build Agent image.
    pause
    exit /b 1
)
echo Agent image built successfully.
echo.

echo [3/6] Building Jenkins image...
docker build -f Dockerfile.jenkins -t code-review-jenkins:latest .
if errorlevel 1 (
    echo ERROR: Failed to build Jenkins image.
    pause
    exit /b 1
)
echo Jenkins image built successfully.
echo.

echo [4/6] Exporting Ollama image to tar file...
echo This will take a few minutes (~5GB file)...
docker save code-review-ollama:latest -o exports\ollama-mistral.tar
echo Done.
echo.

echo [5/6] Exporting Agent image to tar file...
docker save code-review-agent:latest -o exports\agent.tar
echo Done.
echo.

echo [6/6] Exporting Jenkins image to tar file...
docker save code-review-jenkins:latest -o exports\jenkins.tar
echo Done.
echo.

echo ============================================
echo   All images exported to the exports\ folder
echo.
echo   Copy these to your USB drive:
echo   - exports\ollama-mistral.tar  (~5GB)
echo   - exports\agent.tar           (~200MB)
echo   - exports\jenkins.tar         (~600MB)
echo   - docker-compose.yml
echo   - load_and_run.sh
echo   - Jenkinsfile
echo   - jenkins_agent.py
echo   - agent.py
echo   - watched_code\ folder
echo ============================================
pause
