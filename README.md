# Windows Subsystem for Linux Helper
### Setup a new Fedora WSL Distribution with all your favorite dev tools in minutes!

You can deploy almost any Linux distribution to the Windows Subsystem for Linux interface, not just those available in the Microsoft App Store!

In order to quickly deploy a Fedora 33 distribution to WSL:

## Prerequisites

- A Windows 10 system with Powershell that can run Windows Subsystem for Linux: https://docs.microsoft.com/en-us/windows/wsl/faq#what-windows-skus-is-wsl-included-in

## Deployment

### 1) Enable WSL

In Step 2, the Powershell script that is run will check for WSL being installed and if not found will install WSL v1 automatically.

If you'd like install manually beforehand or complete additional instructions to install WSL v2, see the steps here: https://docs.microsoft.com/en-us/windows/wsl/install-win10#manual-installation-steps

### 2) Create a new Fedora WSL Distribution

- In order to create a new WSL distribution for Fedora, download the `setup_fedora_wsl_distro.ps1` Powershell script.
- Open a new Powershell terminal as an Administrator (open the Start Menu, type out "powershell", right click, Run as Administrator)
- Run that script you downloaded, assuming it was downloaded in the Downloads folder under Pat's directory: `C:\Users\Pat\Downloads\setup_fedora_wsl_distro.ps1`

Or you can do all that with this one liner:

```powershell
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/kenmoini/wsl-helper/main/setup_fedora_wsl_distro.ps1; Invoke-Expression $($ScriptFromGitHub.Content)
```

Now you should have a new WSL Distribution based on Fedora!

***Alternatively***, you could also download the Powershell script with this one liner and execute after inspection and modification if you'd like:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kenmoini/wsl-helper/main/setup_fedora_wsl_distro.ps1" -OutFile ".\setup_fedora_wsl_distro.ps1"
```

### 3) Configure the new Fedora WSL Distribution

This is the part where you install all the languages you want, create a new user, configure it how you'd like - thankfully you can do that following the creation of the WSL Distro with the following:

```powershell
wsl -d Fedora33 curl -sSL -o /opt/wsl_setup.sh https://raw.githubusercontent.com/kenmoini/wsl-helper/main/configure_wsl_fedora.sh`
wsl -d Fedora33 bash /opt/wsl_setup.sh
```

It will prompt you for some input, by default it sets up a pretty robust development environment!

You may reset the whole environment and start from scratch by running the single command: `.\setup_fedora_wsl_distro.ps1 -mode reset`

## FAQs

#### What version of WSL has this been tested on?
This has been tested on Windows 10 Pro, WSL v1.  It should support WSL v2 just fine, I happen to not be able to run v2 since I use VMWare Workstation and they can't cohabitate.