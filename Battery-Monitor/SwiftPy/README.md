# Battery-Monitor-Py
extension to battery monitor




cd "/Users/matt/battery monitor/app"

xcodebuild \
  -project "Battery Monitor.xcodeproj" \
  -scheme "Battery Monitor" \
  -configuration Debug \
  -derivedDataPath /private/tmp/battery-monitor-derived-data \
  build

open "/private/tmp/battery-monitor-derived-data/Build/Products/Debug/Battery Monitor.app"