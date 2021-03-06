#
# OS.js Automated Installer for Windows
#
# Copyright 2015 (c) Anders Evenrud <andersevenrud@gmail.com>
#
#
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------

$instdir = $args[0]
$url = "https://github.com/andersevenrud/OS.js-v2/archive/master.zip"
$zipname = "master.zip"
$tmpdir = "$instdir\temp"
$zipfile = "$tmpdir\$zipname"
$outdir = "$tmpdir\OS.js-v2-master\*"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

function unzip($fileName, $sourcePath, $destinationPath) {
    $shell = new-object -com shell.application
    if ( !(Test-Path "$sourcePath\$fileName")) {
        throw "$sourcePath\$fileName does not exist" 
    }
    New-Item -ItemType Directory -Force -Path $destinationPath -WarningAction SilentlyContinue
    $shell.namespace($destinationPath).copyhere($shell.namespace("$sourcePath\$fileName").items()) 
}

# -----------------------------------------------------------------------------
# Make sure we run this script as admin
# -----------------------------------------------------------------------------

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ( ! ($myWindowsPrincipal.IsInRole($adminRole)) ) {
	[System.Windows.Forms.MessageBox]::Show("You need to run this as Administrator") 
	exit
}

# -----------------------------------------------------------------------------
# Then continue installation
# -----------------------------------------------------------------------------

# Make sure directories exist
New-Item $instdir -type directory
New-Item $tmpdir -type directory

# Download latest zip
$client = new-object System.Net.WebClient
$client.DownloadFile( $url, $zipfile )

# Unzip and move files
unzip $zipname $tmpdir $tmpdir
Move-Item $outdir $instdir

# Remove temporary files
Remove-Item $outdir -recurse
Remove-Item $tmpdir -recurse

# Install dependencies and build OS.js
Push-Location $instdir

& npm install -g grunt-cli
& npm install
& grunt --force

# -----------------------------------------------------------------------------
# Finished
# -----------------------------------------------------------------------------
[System.Windows.Forms.MessageBox]::Show("Installation complete. See INSTALL.md on how to run a server.") 
