#!/usr/bin/env pwsh
<#
Run the Flutter app on Windows safely from PowerShell.

This script ensures the console uses UTF-8 to avoid decoding errors,
terminates lingering Dart runtimes that can lock Flutter engine cache files,
and then launches `flutter run -d windows`.

If you need to run without terminating processes, remove the Get-Process line.
Run in a normal (non-admin) PowerShell; elevated may be required to kill some processes.
#>
chcp 65001 | Out-Null
Get-Process dart,dartvm,dartaotruntime -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
flutter run -d windows
