@echo off
:: Open the Play Store page for a package name
adb shell am start market://details?id=%*
