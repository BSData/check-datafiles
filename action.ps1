#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

# check if there are any cat/gst files to process, otherwise short-circuit out
if ((Get-ChildItem -Recurse -Include *.cat, *.gst -File).Length -eq 0) {
    Write-Host "No datafiles to process." -ForegroundColor Green
    exit 0
}

Import-Module $PSScriptRoot/lib/GitHubActionsCore

function PrintAndInvoke{
    param($command)
    Write-Host $command -ForegroundColor Cyan
    Invoke-Expression $command
}
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 1
$env:DOTNET_NOLOGO = 1

# install wham if necessary
$wham = "$PSScriptRoot/lib/wham"
if ($null -eq (Get-Command $wham -ErrorAction SilentlyContinue)) {
    PrintAndInvoke "dotnet tool install wham --version 0.7.0 --tool-path ""$PSScriptRoot/lib"""
}

# read inputs, set output
$stagingPath = Get-ActionInput staging-path -Required
$null = New-Item $stagingPath -ItemType Directory -ErrorAction:Ignore
Set-ActionOutput staging-path $stagingPath

# TODO sometime in future "wham build/ci"

# Publish snapshot to staging path
PrintAndInvoke "$wham publish -f snapshot -o ""$stagingPath"" --verbosity detailed"

Write-Host "Done" -ForegroundColor Green
