@echo off
set HOME=%~dp0
start "My Console" powershell -NoLogo -NoExit -NoProfile -File "%HOME%\Documents\WindowsPowerShell\profile.ps1" -ExecutionPolicy RemoteSigned
