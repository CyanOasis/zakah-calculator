@echo off
rem Zakat & Tazkiyah Calculator - Build Command Wrapper
rem Runs build.ps1 bypassing PowerShell execution restrictions.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*
