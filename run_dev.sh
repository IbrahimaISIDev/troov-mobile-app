#!/bin/bash

# Script to launch the Flutter app with dynamic backend URL
# This detects your computer's local IP address and passes it to Flutter

echo "Starting Troov Mobile App..."

# Get the first local IP address (eth0 or wlan0 usually)
# This works on most Linux/macOS systems
LOCAL_IP=$(hostname -I | awk '{print $1}')

if [ -z "$LOCAL_IP" ]; then
    echo "Warning: Could not detect local IP address."
    echo "Falling back to localhost."
    LOCAL_IP="127.0.0.1"
fi

echo "Detected Local IP: $LOCAL_IP"

# Use the environment variable if provided, otherwise default to local IP
BACKEND_HOST=${1:-$LOCAL_IP}
BACKEND_PORT=8081

# Construct the full API URL
API_URL="http://$BACKEND_HOST:$BACKEND_PORT/api"

echo "====================================================="
echo "Backend URL Configured as: $API_URL"
echo "====================================================="

# Run the flutter app with the injected variable
# We use --dart-define to pass compile-time variables to Dart
flutter run --dart-define=API_URL="$API_URL"
