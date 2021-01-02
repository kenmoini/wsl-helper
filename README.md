# Windows Subsystem for Linux Helper
### Setup a new Fedora WSL Distribution with all your favorite dev tools in minutes!

You can deploy almost any Linux distribution to the Windows Subsystem for Linux interface, not just those available in the Microsoft App Store!

In order to quickly deploy a Fedora 33 distribution to WSL:

### 1) Enable WSL

See instructions here: https://docs.microsoft.com/en-us/windows/wsl/install-win10#manual-installation-steps

### 2) Create a new Fedora WSL Distribution

- In order to create a new WSL distribution for Fedora, download the `setup_fedora_wsl_distro.ps1` Powershell script.
- Open a new Powershell terminal as an Administrator (open the Start Menu, type out "powershell", right click, Run as Administrator)
- Run that script you downloaded, assuming it was downloaded in the Downloads folder under Pat's directory: `C:\Users\Pat\Downloads\setup_fedora_wsl_distro.ps1`

Now you should have a new WSL Distribution based on Fedora!

Double-check by running `wsl -l -v` in the Powershell terminal.

### 3) Configure the new Fedora WSL Distribution

This is the part where you install all the languages you want, create a new user, configure it at you'd like - thankfully you can do that following the creation of the WSL Distro with the following:

`wsl -d Fedora33 curl -sSL -o /opt/wsl_setup.sh https://raw.githubusercontent.com/kenmoini/wsl-helper/main/configure_wsl_fedora.sh`
`wsl -d Fedora33 bash /opt/wsl_setup.sh`

It will prompt you for some input, by default it sets up a pretty robust development environment!