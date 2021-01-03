#!/usr/bin/env bash

function promptNewUserPasswordAndConfirmation {
  echo ""
  read -s -p "Password: " NEW_USER_PASSWORD
  echo ""
  read -s -p "Confirm Password: " NEW_USER_PASSWORD_CONFIRM
  if [ $NEW_USER_PASSWORD != $NEW_USER_PASSWORD_CONFIRM ]; then
    echo ""
    echo "PASSWORDS MUST MATCH!"
    promptNewUserPasswordAndConfirmation
  else
    echo ""
  fi
}

echo "Welcome to the Windows Subsystem for Linux configuration script!"
echo "This will configure a new WSL Fedora instance with some basics to make it feel a little more like home!"

while true; do
  echo ""
  read -n 1 -p "Create a new user? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) CREATE_USER="true"; break;;
    [Nn] ) CREATE_USER="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done
if [ $CREATE_USER = "true" ]; then
  echo ""
  read -p "Username: " NEW_USERNAME
  promptNewUserPasswordAndConfirmation
fi

while true; do
  echo ""
  read -n 1 -p "Install basic development packages? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_DEV_PACKAGES="true"; break;;
    [Nn] ) INSTALL_DEV_PACKAGES="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Install Python 3? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_PYTHON3="true"; break;;
    [Nn] ) INSTALL_PYTHON3="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Install Ansible? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_ANSIBLE="true"; break;;
    [Nn] ) INSTALL_ANSIBLE="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Install PHP? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_PHP="true"; break;;
    [Nn] ) INSTALL_PHP="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Install NodeJS? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_NODEJS="true"; break;;
    [Nn] ) INSTALL_NODEJS="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Install GOLANG? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_GOLANG="true"; break;;
    [Nn] ) INSTALL_GOLANG="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Install ZSH and Oh My ZSH? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_ZSH="true"; break;;
    [Nn] ) INSTALL_ZSH="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Install Kubernetes and OpenShift binaries? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] | "" ) INSTALL_K8S_OCP="true"; break;;
    [Nn] ) INSTALL_K8S_OCP="false"; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

echo ""
echo "Starting..."

## Do a basic system update - DONE
echo ""
echo "Updating base system..."

dnf update -yq

## Do a basic package install - DONE
echo ""
echo "Installing basic packages..."

dnf install -qy chsh wget curl sudo ncurses dnf-plugins-core dnf-utils passwd findutils nano openssl openssh-clients procps-ng git bash-completion jq util-linux-user

## Development Packages - DONE
if [ $INSTALL_DEV_PACKAGES = "true" ]; then
  echo ""
  echo "Installing Developmental Tools..."

  dnf install -yq "@Development Tools"
fi

## ZSH
if [ $INSTALL_ZSH = "true" ]; then
  echo ""
  echo "Installing ZSH, Oh My ZSH, Powerline fonts, thefuck..."

  dnf install -qy zsh
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts && ./install.sh && cd .. && rm -rf fonts/
  pip3 install thefuck
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  cp -R ~/.local /etc/skel
  cp -R ~/.oh-my-zsh /etc/skel
  curl -o /etc/skel/.zshrc https://raw.githubusercontent.com/kenmoini/wsl-helper/main/config/zshrc
  cp /etc/skel/.zshrc ~/.zshrc

  echo 'export PATH=$HOME/.local/bin:$PATH' > /etc/profile.d/local_bin.sh
  chmod +x /etc/profile.d/local_bin.sh
fi

if [ $INSTALL_GOLANG = "true" ]; then
  echo ""
  echo "Installing GOLANG..."

  dnf install -qy golang

  echo 'export GOPATH=$HOME/go' > /etc/profile.d/golang_setup.sh
  echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /etc/profile.d/golang_setup.sh
  chmod +x /etc/profile.d/golang_setup.sh
fi

if [ $INSTALL_PYTHON3 = "true" ]; then
  echo ""
  echo "Installing Python 3..."

  dnf install -qy python3-pip python3 python3-argcomplete
fi

if [ $INSTALL_ANSIBLE = "true" ]; then
  echo ""
  echo "Installing Ansible..."

  pip3 install ansible-base
  pip3 install argcomplete
  register-python-argcomplete ansible | sudo tee /etc/bash_completion.d/python-ansible
  register-python-argcomplete ansible-config | sudo tee /etc/bash_completion.d/python-ansible-config
  register-python-argcomplete ansible-console | sudo tee /etc/bash_completion.d/python-ansible-console
  register-python-argcomplete ansible-doc | sudo tee /etc/bash_completion.d/python-ansible-doc
  register-python-argcomplete ansible-galaxy | sudo tee /etc/bash_completion.d/python-ansible-galaxy
  register-python-argcomplete ansible-inventory | sudo tee /etc/bash_completion.d/python-ansible-inventory
  register-python-argcomplete ansible-playbook | sudo tee /etc/bash_completion.d/python-ansible-playbook
  register-python-argcomplete ansible-pull | sudo tee /etc/bash_completion.d/python-ansible-pull
  register-python-argcomplete ansible-vault | sudo tee /etc/bash_completion.d/python-ansible-vault

  sudo chmod +x /etc/bash_completion.d/python-ansible*
fi

if [ $INSTALL_PHP = "true" ]; then
  echo ""
  echo "Installing PHP and Composer..."

  dnf install -qy php
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php composer-setup.php
  php -r "unlink('composer-setup.php');"
  mv composer.phar /usr/local/bin/composer

  echo 'export PATH=$HOME/.composer/vendor/bin:$PATH' > /etc/profile.d/composer_bin.sh
  chmod +x /etc/profile.d/composer_bin.sh
fi

if [ $INSTALL_NODEJS = "true" ]; then
  echo ""
  echo "Installing NodeJS, NPM, and Yarn..."

  dnf install -qy nodejs npm yarnpkg

  echo 'export PATH=$HOME/.yarn/bin:$PATH' > /etc/profile.d/nodejs_bin.sh
  chmod +x /etc/profile.d/nodejs_bin.sh
fi

if [ $INSTALL_K8S_OCP = "true" ]; then
  echo ""
  echo "Installing K8s and OCP stuff..."

  ## Install OpenShift clients.
  curl -sL -o /tmp/oc-3.10.tar.gz https://mirror.openshift.com/pub/openshift-v3/clients/3.10.176/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-3.10 -zxf /tmp/oc-3.10.tar.gz oc
  curl -sL -o /tmp/oc-3.11.tar.gz https://mirror.openshift.com/pub/openshift-v3/clients/3.11.153/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-3.11 -zxf /tmp/oc-3.11.tar.gz oc
  curl -sL -o /tmp/oc-4.1.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.1/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-4.1 -zxf /tmp/oc-4.1.tar.gz oc
  curl -sL -o /tmp/oc-4.2.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.2/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-4.2 -zxf /tmp/oc-4.2.tar.gz oc
  curl -sL -o /tmp/oc-4.3.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.3/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-4.3 -zxf /tmp/oc-4.3.tar.gz oc
  curl -sL -o /tmp/oc-4.4.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.4/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-4.4 -zxf /tmp/oc-4.4.tar.gz oc
  curl -sL -o /tmp/oc-4.5.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.5/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-4.5 -zxf /tmp/oc-4.5.tar.gz oc
  curl -sL -o /tmp/oc-4.6.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.6/linux/oc.tar.gz
  tar -C /usr/local/bin/oc-4.6 -zxf /tmp/oc-4.5.tar.gz oc
  rm /tmp/oc*.tar.gz

  curl -sL -o /usr/local/bin/odo-0.0.16 https://github.com/openshift/odo/releases/download/v0.0.16/odo-linux-amd64
  curl -sL -o /usr/local/bin/odo-0.0.17 https://github.com/openshift/odo/releases/download/v0.0.17/odo-linux-amd64
  curl -sL -o /usr/local/bin/odo-0.0.18 https://github.com/openshift/odo/releases/download/v0.0.18/odo-linux-amd64
  curl -sL -o /usr/local/bin/odo-0.0.19 https://github.com/openshift/odo/releases/download/v0.0.19/odo-linux-amd64
  curl -sL -o /usr/local/bin/odo-0.0.20 https://github.com/openshift/odo/releases/download/v0.0.20/odo-linux-amd64
  curl -sL -o /usr/local/bin/odo-1.0.0 https://mirror.openshift.com/pub/openshift-v4/clients/odo/v1.0.0/odo-darwin-amd64
  curl -sL -o /usr/local/bin/odo-1.2.6 https://mirror.openshift.com/pub/openshift-v4/clients/odo/v1.2.6/odo-darwin-amd64
  curl -sL -o /usr/local/bin/odo-2.0.0 https://mirror.openshift.com/pub/openshift-v4/clients/odo/v2.0.0/odo-darwin-amd64
  curl -sL -o /usr/local/bin/odo-2.0.1 https://mirror.openshift.com/pub/openshift-v4/clients/odo/v2.0.1/odo-darwin-amd64
  curl -sL -o /usr/local/bin/odo-2.0.2 https://mirror.openshift.com/pub/openshift-v4/clients/odo/v2.0.2/odo-darwin-amd64
  curl -sL -o /usr/local/bin/odo-2.0.3 https://mirror.openshift.com/pub/openshift-v4/clients/odo/v2.0.3/odo-darwin-amd64

  # Install Kubernetes client.
  curl -sL -o /usr/local/bin/kubectl-1.10 https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.11 https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.12 https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.13 https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.14 https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.15 https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.16 https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.17 https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.18 https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.19 https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
  curl -sL -o /usr/local/bin/kubectl-1.20 https://storage.googleapis.com/kubernetes-release/release/v1.20.0/bin/linux/amd64/kubectl

  curl -sL -o /usr/local/bin/kubectl https://raw.githubusercontent.com/kenmoini/wsl-helper/main/root_path/usr/local/bin/kubectl
  curl -sL -o /usr/local/bin/oc https://raw.githubusercontent.com/kenmoini/wsl-helper/main/root_path/usr/local/bin/oc
  curl -sL -o /usr/local/bin/odo https://raw.githubusercontent.com/kenmoini/wsl-helper/main/root_path/usr/local/bin/odo

  chmod +x /usr/local/bin/kubectl*
  chmod +x /usr/local/bin/odo*
  chmod +x /usr/local/bin/oc*

  echo "source <(kubectl completion bash)" > /etc/profile.d/kubectl_completion.sh
  chmod +x /etc/profile.d/kubectl_completion.sh

  echo "source <(oc completion bash)" > /etc/profile.d/oc_completion.sh
  echo "alias oc='oc --insecure-skip-tls-verify'" >> /etc/profile.d/oc_completion.sh
  chmod +x /etc/profile.d/oc_completion.sh
fi

## Create a user - DONE
if [ $CREATE_USER = "true" ]; then
  useradd $NEW_USERNAME; echo $NEW_USER_PASSWORD | passwd $NEW_USERNAME --stdin

  if [ $INSTALL_ZSH = "true" ]; then
    chsh --shell $(which zsh) $NEW_USERNAME
  fi
fi