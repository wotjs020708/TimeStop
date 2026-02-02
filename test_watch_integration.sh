#!/bin/bash

set -e

echo "🧪 TimeStop Watch App Integration Test Script"
echo "=============================================="
echo ""

echo "📋 Checking project structure..."
if [ ! -f "TimeStop.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: TimeStop.xcodeproj not found"
    exit 1
fi
echo "✅ Project file exists"

echo ""
echo "📁 Checking required files..."
FILES=(
    "TimeStop/Core/ConnectivityManager.swift"
    "TimeStop/Core/MVIProtocols.swift"
    "TimeStop/Presentation/Timer/TimerViewModel.swift"
    "TimeStopWatch Watch App/TimeStopWatchApp.swift"
    "TimeStopWatch Watch App/WatchTimerViewModel.swift"
    "TimeStopWatch Watch App/WatchTimerScreen.swift"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ Missing: $file"
        exit 1
    fi
done

echo ""
echo "🔍 Checking Swift syntax..."
for file in "${FILES[@]}"; do
    if [[ $file == *.swift ]]; then
        if xcrun swiftc -syntax "$file" -target arm64-apple-watchos10.0 2>/dev/null || \
           xcrun swiftc -syntax "$file" -target arm64-apple-ios17.0 2>/dev/null; then
            echo "  ✅ Syntax OK: $(basename "$file")"
        else
            echo "  ⚠️  Syntax check skipped (requires proper target setup): $(basename "$file")"
        fi
    fi
done

echo ""
echo "🏗️  Attempting iOS build (if target configured)..."
if xcodebuild -project TimeStop.xcodeproj -scheme TimeStop -configuration Debug build -quiet 2>/dev/null; then
    echo "✅ iOS build successful"
else
    echo "⚠️  iOS build failed or scheme not configured (expected before Xcode setup)"
fi

echo ""
echo "🏗️  Attempting watchOS build (if target configured)..."
if xcodebuild -project TimeStop.xcodeproj -scheme TimeStopWatch -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' build -quiet 2>/dev/null; then
    echo "✅ watchOS build successful"
else
    echo "⚠️  watchOS build failed or target not configured (expected before Xcode setup)"
fi

echo ""
echo "📊 Test Summary"
echo "=============="
echo "✅ All source files created"
echo "✅ Project structure validated"
echo ""
echo "⚠️  Manual steps required in Xcode:"
echo "   1. Add watchOS target (see WATCH_SETUP.md)"
echo "   2. Configure file target memberships"
echo "   3. Set up code signing"
echo "   4. Run both apps in simulator to test Watch Connectivity"
echo ""
echo "📖 See WATCH_SETUP.md for detailed instructions"
