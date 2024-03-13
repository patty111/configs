# for auto completion
Set-PSReadLineOption -PredictionViewStyle ListView

[System.Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'
[System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'


# Import Terminal Icons -> decent & pretty little icons
Import-Module -Name Terminal-Icons


$wt = "$env:APPDATA\..\Local\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe"

# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context
# Useful shortcuts for traversing directories
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

# Compute file hashes - useful for checking successful downloads 
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }


# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    } else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
}

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin {
    if ($args.Count -gt 0) {   
        $argList = "& '" + $args + "'"
        Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argList
    } else {
        Start-Process "$wt" -Verb runAs
    }
}

Set-Alias -Name sudo -Value admin
Set-Alias -Name i -Value code-insiders

# list all files only (no dirs)
function ll { Get-ChildItem -Path $pwd -File }
# directly direct to Github folder
function g { Set-Location $HOME\Documents\Github }
# open command in linux
function open($dir){
	Invoke-Item $dir
}
# grep
function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}
# process kill
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
# process list with grep
function pgrep($name) {
    Get-Process $name
}
# find file by name
function find-file($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}
# get my ip
function my-ip {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}
# reboot/shutdown
function reboot {
    param(
        [switch]$f
    ) # with -f flag to force reboot
    if ($f) {
        Restart-Computer -Force
    } else {
        Restart-Computer
    }
}
function shutdown {
    param(
        [switch]$f
    )
    if ($f) {
        Stop-Computer -Force
    } else {
        Stop-Computer
    }
}

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin_latte.omp.json" | Invoke-Expression

# removed vars no longer in need
Remove-Variable identity
Remove-Variable principal
