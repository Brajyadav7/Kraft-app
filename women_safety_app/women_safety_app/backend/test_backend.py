"""
Quick test script to verify backend is working
Run this after starting the backend to test the AI connection
"""

import requests
import json

BACKEND_URL = "http://127.0.0.1:5000"

def test_health():
    """Test health endpoint"""
    print("🔍 Testing health endpoint...")
    try:
        response = requests.get(f"{BACKEND_URL}/api/health", timeout=5)
        print(f"✅ Health check: {response.status_code}")
        print(f"   Response: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False

def test_chat():
    """Test chat endpoint"""
    print("\n🔍 Testing chat endpoint...")
    try:
        payload = {
            "message": "I'm feeling scared walking alone at night. What should I do?",
            "context": {
                "type": "chat",
                "timestamp": "2026-01-25T12:00:00"
            }
        }
        response = requests.post(
            f"{BACKEND_URL}/api/ai/chat",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        print(f"✅ Chat test: {response.status_code}")
        data = response.json()
        print(f"   Response preview: {data.get('response', 'No response')[:200]}...")
        return True
    except Exception as e:
        print(f"❌ Chat test failed: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("🧪 Backend Connection Test")
    print("=" * 60)
    print(f"\nTesting backend at: {BACKEND_URL}")
    print("Make sure the backend is running before running this test!\n")
    
    health_ok = test_health()
    if health_ok:
        test_chat()
    else:
        print("\n❌ Backend is not running or not accessible!")
        print("   Start it with: python app.py")
    
    print("\n" + "=" * 60)

