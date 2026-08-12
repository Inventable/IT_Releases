[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
$rootPath = [IO.Path]::GetFullPath($Root)

function Require([bool]$Condition, [string]$Message) {
    if (!$Condition) { throw $Message }
}

function Test-Sha256([string]$Value, [string]$Field) {
    Require ($Value -match '^[0-9A-Fa-f]{64}$') "$Field must be a SHA-256 value."
}

function Test-Commit([string]$Value, [string]$Field) {
    Require ($Value -match '^[0-9A-Fa-f]{40}$') "$Field must be a 40-character source commit."
}

function Test-Https([string]$Value, [string]$Field) {
    $uri = $null
    Require ([Uri]::TryCreate($Value, [UriKind]::Absolute, [ref]$uri) -and $uri.Scheme -eq 'https') "$Field must be an absolute HTTPS URL."
}

$stablePath = Join-Path $rootPath "channels/stable.json"
Require (Test-Path -LiteralPath $stablePath -PathType Leaf) "Missing stable release catalogue."
$stable = Get-Content -LiteralPath $stablePath -Raw | ConvertFrom-Json
Require ($stable.schemaVersion -eq 1) "Stable catalogue must use schema 1."
Require ($stable.channel -eq 'stable') "Stable catalogue channel must be stable."
Require ($stable.suiteVersion -match '^\d+\.\d+\.\d+$') "Stable suite version is invalid."
Test-Commit ([string]$stable.application.sourceCommit) "Stable application source commit"
Test-Https ([string]$stable.application.url) "Stable application URL"
Test-Sha256 ([string]$stable.application.sha256) "Stable application hash"
foreach ($release in $stable.firmware) {
    Require ($release.imageType -eq 'offset-production') "Stable firmware must use offset-production images."
    Require ($release.processor -eq 'PIC18F26K80') "Stable firmware processor is invalid."
    Test-Commit ([string]$release.sourceCommit) "Stable firmware source commit"
    Test-Https ([string]$release.url) "Stable firmware URL"
    Test-Sha256 ([string]$release.sha256) "Stable firmware hash"
}

$betaPath = Join-Path $rootPath "channels/beta/current.json"
if (Test-Path -LiteralPath $betaPath -PathType Leaf) {
    $beta = Get-Content -LiteralPath $betaPath -Raw | ConvertFrom-Json
    Require ($beta.schemaVersion -eq 2) "Beta catalogue must use schema 2."
    Require ($beta.channel -eq 'beta') "Beta catalogue channel must be beta."
    Require ($beta.suiteVersion -match '^\d{4}\.\d+\.\d+-beta(?:\.\d+)?$') "Beta suite version is invalid."
    Require ($beta.source.repository -eq 'Inventable/Gauge_Product_Family') "Beta source repository is invalid."
    Test-Commit ([string]$beta.source.commit) "Beta source commit"
    Require (!$beta.source.dirty) "Beta source must be clean."

    Require (@($beta.applications).Count -ge 1) "Beta catalogue must include an application."
    foreach ($application in $beta.applications) {
        Require ($application.version -match '^\d+\.\d+\.\d+-beta$') "Beta application version is invalid."
        Test-Https ([string]$application.url) "Beta application URL"
        Test-Sha256 ([string]$application.sha256) "Beta application hash"
    }

    Require (@($beta.firmware).Count -ge 1) "Beta catalogue must include firmware."
    foreach ($release in $beta.firmware) {
        Require ($release.imageType -eq 'offset-production') "Beta firmware must use offset-production images."
        Require ($release.processor -eq 'PIC18F26K80') "Beta firmware processor is invalid."
        Test-Https ([string]$release.url) "Beta firmware URL"
        Test-Sha256 ([string]$release.sha256) "Beta firmware hash"
    }

    foreach ($asset in @($beta.additionalAssets)) {
        Test-Https ([string]$asset.url) "Beta additional-asset URL"
        Test-Sha256 ([string]$asset.sha256) "Beta additional-asset hash"
    }
}

Write-Output "RELEASE_REPOSITORY_VALID root=$rootPath"
