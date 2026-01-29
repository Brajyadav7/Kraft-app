import requests
import json

API_KEY = "AIzaSyBs1jbm0hxUyYzg1_uAyERuXAU3AN7RQ4A"

print(f"Testing API Key: {API_KEY[:5]}...{API_KEY[-5:]}")

# 1. List Models to see what's available
print("\n--- Listing Models ---")
url = f"https://generativelanguage.googleapis.com/v1beta/models?key={API_KEY}"
try:
    response = requests.get(url, timeout=10)
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        if 'models' in data:
            print("Available models:")
            for m in data['models']:
                if 'generateContent' in m['supportedGenerationMethods']:
                    print(f" - {m['name']}")
        else:
            print("No models found in response")
            print(data)
    else:
        print(f"Error: {response.text}")
except Exception as e:
    print(f"Exception listing models: {e}")

# 2. Test Generation with a specific model (gemini-1.5-flash)
print("\n--- Testing Generation (gemini-1.5-flash) ---")
test_url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={API_KEY}"
payload = {
    "contents": [{"parts": [{"text": "Hello, are you working?"}]}]
}
try:
    response = requests.post(test_url, headers={'Content-Type': 'application/json'}, json=payload, timeout=10)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text[:200]}...") # Print first 200 chars
except Exception as e:
    print(f"Exception testing generation: {e}")
