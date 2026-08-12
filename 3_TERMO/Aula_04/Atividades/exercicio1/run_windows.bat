@echo off
rem Use code page 65001 (UTF-8) to avoid console decoding errors
chcp 65001 >nul
rem Kill common Dart runtime processes that can lock engine cache files
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM dartvm.exe /T 2>nul
taskkill /F /IM dartaotruntime.exe /T 2>nul

rem Launch Flutter for Windows
flutter run -d windows
