# AI/ML Framework Installer (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.ps1 | iex

param(
    [string]$TargetDir = ".github"
)

$Repo   = "thieunv96/agentic_ai"
$Branch = "main"
$ArchiveUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"

function Write-Info    { Write-Host "[ai] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[ai] $args" -ForegroundColor Green }
function Write-Err     { Write-Host "[ai] $args" -ForegroundColor Red; exit 1 }

Write-Info "Installing AI/ML framework into $TargetDir/ ..."

# Create temp directory
$Tmp = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path "$($_.FullName)" }

try {
    # Download archive
    Write-Info "Downloading from $Repo ..."
    $ZipPath = Join-Path $Tmp.FullName "archive.zip"
    Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ZipPath -UseBasicParsing

    # Extract
    $ExtractPath = Join-Path $Tmp.FullName "extracted"
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath

    # Strip top-level directory (GitHub zips add a root folder)
    $InnerDir = Get-ChildItem -Path $ExtractPath -Directory | Select-Object -First 1

    # Verify ai/ exists
    $AiDir = Join-Path $InnerDir.FullName "ai"
    if (-not (Test-Path $AiDir)) {
        Write-Err "Expected 'ai/' directory not found in archive. Repository structure may have changed."
    }

    # Read version
    $VersionFile = Join-Path $AiDir "my\VERSION"
    $Version = if (Test-Path $VersionFile) { Get-Content $VersionFile -Raw | ForEach-Object { $_.Trim() } } else { "" }

    # Create target and copy
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Copy-Item -Path "$AiDir\*" -Destination $TargetDir -Recurse -Force

    # Verify
    if (-not (Test-Path (Join-Path $TargetDir "copilot-instructions.md"))) {
        Write-Err "Installation incomplete — copilot-instructions.md not found in $TargetDir/"
    }

    $VersionDisplay = if ($Version) { "v$Version" } else { "" }
    Write-Success "Framework $VersionDisplay installed into $TargetDir/"
    Write-Host ""
    Write-Host "  Next steps:"
    Write-Host "  1. Open your project in Claude Code (or GitHub Copilot)"
    Write-Host "  2. The .github/ directory is auto-loaded as custom instructions"
    Write-Host "  3. Run /my-new-version to start your first version"
    Write-Host ""
}
finally {
    Remove-Item -Recurse -Force $Tmp.FullName -ErrorAction SilentlyContinue
}
