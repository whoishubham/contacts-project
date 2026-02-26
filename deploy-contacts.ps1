```powershell
<#
.SYNOPSIS
    Creates contacts.txt in Documents folder and pushes it to a GitHub repository.

.DESCRIPTION
    - Creates/updates contacts.txt with predefined content.
    - Initializes Git repository if not already initialized.
    - Adds and commits the file (only if changes exist).
    - Pushes to configured GitHub remote.
    - Idempotent and safe to run multiple times.
#>

# Stop on all non-terminating errors
$ErrorActionPreference = "Stop"

try {
    # -------------------------------
    # Step 1: Create contacts.txt
    # -------------------------------

    # Get current user's Documents folder
    $documentsPath = [Environment]::GetFolderPath("MyDocuments")
    $filePath = Join-Path $documentsPath "contacts.txt"

    # Define exact file content
    $fileContent = @"
Name - Shubham Negi - 8859269510
Name - Suraj Sharma - 8826862592
"@

    # Create or overwrite file only if content differs (idempotent)
    if (Test-Path $filePath) {
        $existingContent = Get-Content $filePath -Raw
        if ($existingContent -ne $fileContent) {
            Set-Content -Path $filePath -Value $fileContent -Encoding UTF8
            Write-Host "Updated contacts.txt"
        }
        else {
            Write-Host "contacts.txt already up to date"
        }
    }
    else {
        Set-Content -Path $filePath -Value $fileContent -Encoding UTF8
        Write-Host "Created contacts.txt"
    }

    # Change directory to Documents
    Set-Location $documentsPath

    # -------------------------------
    # Step 2: Git Initialization
    # -------------------------------

    # Check if .git folder exists
    if (-not (Test-Path (Join-Path $documentsPath ".git"))) {
        git init | Out-Null
        Write-Host "Initialized new Git repository"
    }
    else {
        Write-Host "Git repository already initialized"
    }

    # Add file to staging
    git add contacts.txt

    # Check if there are staged changes before committing
    $changes = git status --porcelain
    if ($changes) {
        git commit -m "Added contacts file" | Out-Null
        Write-Host "Committed changes"
    }
    else {
        Write-Host "No changes to commit"
    }

    # -------------------------------
    # Push to GitHub
    # -------------------------------

    # Check if remote exists
    $remote = git remote
    if (-not $remote) {
        throw "No Git remote configured. Please add a GitHub remote before running this script."
    }

    # Get current branch
    $currentBranch = git rev-parse --abbrev-ref HEAD

    # Push to remote
    git push -u origin $currentBranch
    Write-Host "Pushed to GitHub successfully"

}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}
```
