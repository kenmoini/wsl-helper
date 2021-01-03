param (
  [switch]$reset = $false,
  [switch]$remove = $false,
  [switch]$keepCache = $false
)

$fedora_major_version = "33"
$fedora_version = "33.20201230"
$wsl_distro_root_path = "C:\WSLDistros"

if ($reset) {
  echo ""
  echo "Removing Fedora$fedora_major_version from current WSL distributions and resetting..."
  wsl --unregister "Fedora$fedora_major_version"
}
if ($remove) {
  echo ""
  echo "Removing Fedora$fedora_major_version from current WSL distributions and resetting..."
  wsl --unregister "Fedora$fedora_major_version"
  exit
}

echo ""
echo "Deploying a new Fedora $fedora_major_version WSL distribution!"
echo ""

if ((Get-Command "wsl.exe" -ErrorAction SilentlyContinue) -eq $null) 
{ 
  echo "Unable to find WSL installed!  Installing now..."
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
}

echo ""
echo "Fedora $fedora_major_version distribution setup starting..."
echo ""

# Create Temp dir
echo "Creating temporary directories..."
if (!(Test-Path "C:\Temp\")) {
  [void](New-Item -ItemType directory -Path C:\Temp)
}
# Create Temp Sub dir
if (!(Test-Path "C:\Temp\fedoraWSL\")) {
  [void](New-Item -ItemType directory -Path C:\Temp\fedoraWSL)
}
# Create Temp Sub dir for xz
if (!(Test-Path "C:\Temp\fedoraWSL\xz\")) {
  [void](New-Item -ItemType directory -Path C:\Temp\fedoraWSL\xz)
}

echo "Creating WSL directories..."
# Create WSL Distro directory if needed
if (!(Test-Path $wsl_distro_root_path)) {
  [void](New-Item -ItemType directory -Path $wsl_distro_root_path)
}
if (!(Test-Path "$wsl_distro_root_path/Fedora$fedora_major_version")) {
  [void](New-Item -ItemType directory -Path "$wsl_distro_root_path/Fedora$fedora_major_version")
}

echo "Downloading xz..."
if (!(Test-Path "C:\Temp\fedoraWSL\xz\xz.zip")) {
  # Get xz for windows
  Invoke-WebRequest -Uri "https://tukaani.org/xz/xz-5.2.5-windows.zip" -OutFile "C:\Temp\fedoraWSL\xz\xz.zip"

  # Unzip xz for Windows
  echo "Extracing xz..."
  Expand-Archive -LiteralPath 'C:\Temp\fedoraWSL\xz\xz.zip' -DestinationPath C:\Temp\fedoraWSL\xz
}

echo "Downloading Fedora 33 system root..."
if (!(Test-Path "C:\Temp\fedoraWSL\fedora_root.tar.xz") && !(Test-Path "C:\Temp\fedoraWSL\fedora_root.tar")) {
  # Get Fedora system root file
  Invoke-WebRequest -Uri "https://github.com/fedora-cloud/docker-brew-fedora/raw/$fedora_major_version/x86_64/fedora-$fedora_version-x86_64.tar.xz" -OutFile "C:\Temp\fedoraWSL\fedora_root.tar.xz"

  # Run xz against the system root file
  echo "Inflating system root archive..."
  C:\Temp\fedoraWSL\xz\bin_x86-64\xz.exe -df C:\Temp\fedoraWSL\fedora_root.tar.xz
}

# Import the base system root
if (Test-Path "C:\Temp\fedoraWSL\fedora_root.tar") {
  echo "Importing Fedora 33 system root into new WSL distribution..."
  wsl --import Fedora$fedora_major_version $wsl_distro_root_path/Fedora$fedora_major_version C:\Temp\fedoraWSL\fedora_root.tar
}

# Clean up
if (!$keepCache) {
  echo "Cleaning up temporary files..."
  Remove-Item -LiteralPath "C:\Temp\fedoraWSL" -Force -Recurse
}

echo ""
echo "Setup complete!"
echo ""

if ($reset) {
  wsl -d "Fedora$fedora_major_version" curl -sSL -o /opt/wsl_setup.sh https://raw.githubusercontent.com/kenmoini/wsl-helper/main/configure_wsl_fedora.sh
  wsl -d "Fedora$fedora_major_version" bash /opt/wsl_setup.sh
}
else {
  echo "Your current WSL Distributions:"
  wsl -l -v
}