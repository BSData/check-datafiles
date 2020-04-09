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

# install wham if necessary
$wham = "$PSScriptRoot/lib/wham"
if ($null -eq (Get-Command $wham -ErrorAction SilentlyContinue)) {
    $env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 1
    $env:DOTNET_NOLOGO = 'true'
    PrintAndInvoke "dotnet tool install wham --version 0.7.0 --tool-path ""$PSScriptRoot/lib"""
}

# read inputs, set output
$stagingPath = Get-ActionInput staging-path -Required
Set-ActionOutput staging-path $stagingPath

# TODO "wham build/ci"

# Publish snapshot
PrintAndInvoke """$wham"" publish -f snapshot -o ""$stagingPath"" --verbosity detailed"

Write-Host "Done" -ForegroundColor Green
