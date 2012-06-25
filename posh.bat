@echo off
set HOME=%~dp0
start "My Console" powershell -NoLogo -NoExit -NoProfile -ExecutionPolicy RemoteSigned -File "%HOME%\Documents\WindowsPowerShell\profile.ps1"
