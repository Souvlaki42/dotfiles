# Powershell profile v0.2 by [Souvlaki42](https://github.com/Souvlaki42)

# Function to update Powershell
function update {
    try {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true
        }

        if ($updateNeeded) {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            winget upgrade --id "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements --source winget
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}

# Initialize oh-my-posh with my configuration file
oh-my-posh init pwsh --config ~/shell.toml | Invoke-Expression

# Initialize zoxide as the default cd command
Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })

# Enable the syntax highlighting module
Import-Module -Name syntax-highlighting

# Enable the terminal icons module
Import-Module -Name Terminal-Icons

# Aliases
Set-Alias -Name cl -Value Clear-Host
Set-Alias -Name sysinfo -Value Get-ComputerInfo
Set-Alias -Name flushdns -Value Clear-DnsClientCache
Set-Alias -Name cat -Value bat
Set-Alias -Name lg -Value lazygit
Set-Alias -Name pn -Value pnpm
Set-Alias -Name v -Value nvim
Set-Alias -Name c -Value code
Set-Alias -Name rm -Value gomi
Set-Alias -Name nc -Value ncat

# Built-in functions
function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }

function export($name, $value) { set-item -force -path "env:$name" -value $value; }

function pkill($name) { Get-Process $name -ErrorAction SilentlyContinue | Stop-Process }

function pgrep($name) { Get-Process $name }

function touch($file) { "" | Out-File $file -Encoding ASCII }

function fetch { fastfetch --gpu-driver-specific @args }

function glo { git log --graph --oneline --decorate @args }

function unzip($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

# Eza aliases/functions
function ls { eza @args }
function la { eza -a @args }
function ll { eza -alh @args }
function tree { eza --tree @args }

# Network Utilities
function ipv4 { curl https://api.ipify.org }
function ipv6 { curl https://api64.ipify.org }

# Clipboard Utilities
function cpy($contents) { Set-Clipboard $contents }
function pst { Get-Clipboard }

# Checksums
function md5($file) { Get-FileHash $file -Algorithm MD5 }
function sha256($file) { Get-FileHash $file -Algorithm SHA256 }
