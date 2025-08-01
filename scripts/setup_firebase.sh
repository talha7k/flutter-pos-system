#!/bin/bash

# Firebase Setup Script for Flutter POS System
# This script helps developers set up Firebase configuration safely

set -e

echo "🔥 Firebase Setup for Flutter POS System"
echo "========================================"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed."
    echo "Please install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null; then
    echo "❌ FlutterFire CLI is not installed."
    echo "Please install it with: dart pub global activate flutterfire_cli"
    exit 1
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo "❌ You are not logged in to Firebase."
    echo "Please login with: firebase login"
    exit 1
fi

echo "✅ Prerequisites check passed!"
echo ""

# Run FlutterFire configure
echo "🔧 Configuring FlutterFire..."
echo "This will generate firebase_options.dart with your project's configuration."
echo ""

flutterfire configure

echo ""
echo "✅ Firebase configuration completed!"
echo ""
echo "📋 Next steps:"
echo "1. Ensure your Firebase project has the necessary services enabled"
echo "2. Configure Firebase Security Rules for your database"
echo "3. Set up Firebase App Check for additional security"
echo "4. Review the FIREBASE_SETUP.md file for more details"
echo ""
echo "⚠️  Security reminder:"
echo "- Never commit firebase_options.dart to version control"
echo "- Keep your API keys secure and rotate them regularly"
echo "- Monitor your Firebase usage for unusual activity"
echo ""
echo "🎉 Setup complete! You can now run your Flutter app."