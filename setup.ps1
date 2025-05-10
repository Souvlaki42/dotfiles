# Checks if python3 or python is installed
[string]$PYTHON = "python3"
if (-Not (Get-Command python3 -ErrorAction SilentlyContinue)) {
    if (-Not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Host "Error: Python not found. Please install Python 3.x."
        Write-Host "You can download it from https://www.python.org/downloads/."
        Write-Host "You can also install it using Winget: 'winget install python'."
        Write-Host "Using scoop: 'scoop install python'."
        Write-Host "Using chocolatey: 'choco install python3'."
        Exit 1
    } else {
        $PYTHON = "python"
    }
}

# Checks if git is installed
if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Git not found. Please install Git."
    Write-Host "You can download it from https://git-scm.com/download/win."
    Write-Host "You can also install it using Winget: 'winget install git'."
    Write-Host "Using scoop: 'scoop install git'."
    Write-Host "Using chocolatey: 'choco install git'."
    Exit 1
}

# Checks if syntax highlighting powershell module is installed
if (-Not (Get-Module -ListAvailable -Name syntax-highlighting)) {
    Write-Host "Error: Powershell syntax highlighting module not found."
    Write-Host "Installing syntax highlighting module..."
    Install-Module syntax-highlighting -Scope CurrentUser
}

# Checks if terminal icons powershell module is installed
if (-Not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "Error: Powershell terminal icons module not found."
    Write-Host "Installing terminal icons module..."
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
}

# Clones the repository if it doesn't exist
if (-Not (Test-Path "$HOME\dotfiles")) {
    Write-Host "Cloning dotfiles repository..."
    git clone --depth 1 https://github.com/Souvlaki42/dotfiles.git "$HOME\dotfiles" || Write-Host "Error: Failed to clone dotfiles repository. Please try again." && Exit 1
    Set-Location "$HOME\dotfiles"
} else {
    Write-Host "Updating dotfiles repository..."
    Set-Location "$HOME\dotfiles"
    git pull
}

# Installs the dotfiles
Write-Host "Installing dotfiles..."
& $PYTHON manager\main.py