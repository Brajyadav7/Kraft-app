#!/bin/bash

# macOS/Linux Script to Start Women Safety App Backend
# This script sets up and runs the Flask backend

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Women Safety App - Custom AI Backend Starter         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: Python3 is not installed"
    echo "Please install Python 3.8+ from https://www.python.org/"
    exit 1
fi

echo "✅ Python found:"
python3 --version
echo ""

# Check if we're in the backend directory
if [ ! -f "app.py" ]; then
    echo "❌ ERROR: app.py not found"
    echo "Please run this script from the backend directory"
    echo "Expected: cd women_safety_app/backend && ./start_backend.sh"
    exit 1
fi

echo "📁 Current directory: $(pwd)"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "❌ Failed to create virtual environment"
        exit 1
    fi
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo ""
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install requirements if needed
if ! python3 -c "import flask" 2>/dev/null; then
    echo ""
    echo "📥 Installing required packages..."
    echo "This may take a minute..."
    echo ""
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install requirements"
        exit 1
    fi
    echo "✅ Packages installed successfully"
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Run the backend
echo ""
echo "🚀 Starting Women Safety App Backend..."
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              Backend is starting...                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📡 Server will be available at: http://127.0.0.1:5000"
echo ""
echo "🔗 API Endpoints:"
echo "   - Health Check:   GET http://127.0.0.1:5000/api/health"
echo "   - Chat:          POST http://127.0.0.1:5000/api/ai/chat"
echo "   - Support:       POST http://127.0.0.1:5000/api/ai/support"
echo "   - Area Safety:   POST http://127.0.0.1:5000/api/ai/area-safety"
echo "   - Threat:        POST http://127.0.0.1:5000/api/ai/threat-assessment"
echo ""
echo "📋 To test, open another terminal and run:"
echo "   curl http://127.0.0.1:5000/api/health"
echo ""
echo "⏹️  Press Ctrl+C to stop the server"
echo ""

python3 app.py

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ ERROR: Backend failed to start"
    echo "Check the error messages above"
    exit 1
fi
