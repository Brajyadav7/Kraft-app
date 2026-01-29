@echo off
REM Windows Script to Start Women Safety App Backend
REM This script sets up and runs the Flask backend

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   Women Safety App - Custom AI Backend Starter         ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo ✅ Python found: 
python --version
echo.

REM Check if we're in the backend directory
if not exist "app.py" (
    echo ❌ ERROR: app.py not found
    echo Please run this script from the backend directory
    echo Expected: cd women_safety_app\backend\ ^&^& start_backend.bat
    pause
    exit /b 1
)

echo 📁 Current directory: %cd%
echo.

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo 📦 Creating Python virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
    echo ✅ Virtual environment created
)

REM Activate virtual environment
echo.
echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Install requirements if needed
if not exist "venv\Lib\site-packages\flask" (
    echo.
    echo 📥 Installing required packages...
    echo This may take a minute...
    echo.
    pip install -r requirements.txt
    if errorlevel 1 (
        echo ❌ Failed to install requirements
        pause
        exit /b 1
    )
    echo ✅ Packages installed successfully
)

REM Create logs directory if it doesn't exist
if not exist "logs" (
    mkdir logs
)

REM Run the backend
echo.
echo 🚀 Starting Women Safety App Backend...
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║              Backend is starting...                     ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 📡 Server will be available at: http://127.0.0.1:5000
echo.
echo 🔗 API Endpoints:
echo    - Health Check:   GET http://127.0.0.1:5000/api/health
echo    - Chat:          POST http://127.0.0.1:5000/api/ai/chat
echo    - Support:       POST http://127.0.0.1:5000/api/ai/support
echo    - Area Safety:   POST http://127.0.0.1:5000/api/ai/area-safety
echo    - Threat:        POST http://127.0.0.1:5000/api/ai/threat-assessment
echo.
echo 📋 To test, open another terminal and run:
echo    curl http://127.0.0.1:5000/api/health
echo.
echo ⏹️  Press Ctrl+C to stop the server
echo.

python app.py

if errorlevel 1 (
    echo.
    echo ❌ ERROR: Backend failed to start
    echo Check the error messages above
    pause
    exit /b 1
)

pause
