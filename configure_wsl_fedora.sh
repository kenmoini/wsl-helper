#!/usr/bin/env bash

cd $HOME

function promptNewUserPasswordAndConfirmation {
  echo ""
  read -s -p "Password: " NEW_USER_PASSWORD
  echo ""
  read -s -p "Confirm Password: " NEW_USER_PASSWORD_CONFIRM
  if [[ $NEW_USER_PASSWORD != $NEW_USER_PASSWORD_CONFIRM ]]; then
    echo ""
    echo "PASSWORDS MUST MATCH!"
    promptNewUserPasswordAndConfirmation
  else
    echo ""
    export NEW_USER_PASSWORD=$NEW_USER_PASSWORD
    export NEW_USER_PASSWORD_CONFIRM=$NEW_USER_PASSWORD_CONFIRM
  fi
}

echo ""
echo "--------------------------------------------------------------------------------"
echo "Welcome to the Windows Subsystem for Linux configuration script!"
echo ""
echo "This will configure a new WSL Fedora instance with some basics to make it"
echo "feel a little more like home!"
echo "--------------------------------------------------------------------------------"
echo ""

while true; do
  echo ""
  read -n 2 -p "Language pack to install [en] " LANGPACK
  case $LANGPACK in
    "" ) export INSTALL_LANGPACK="en"; break;;
    * ) export INSTALL_LANGPACK=$LANGPACK; break;;
  esac
done

while true; do
  echo ""
  read -n 1 -p "Create a new user? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export CREATE_USER="true"; echo ""; break;;
    "" ) export CREATE_USER="true"; break;;
    [Nn] ) export CREATE_USER="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done
if [[ $CREATE_USER == "true" ]]; then
  echo ""
  read -p "Username: " NEW_USERNAME
  promptNewUserPasswordAndConfirmation
fi
if [[ $CREATE_USER == "true" ]]; then
  while true; do
    echo ""
    read -n 1 -p "Add user to wheel group (sudoer)? [Y/n] " YNPROMPT
    case $YNPROMPT in
      [Yy] ) export NEW_USER_TO_WHEEL="true"; echo ""; break;;
      "" ) export NEW_USER_TO_WHEEL="true"; break;;
      [Nn] ) export NEW_USER_TO_WHEEL="false"; echo ""; break;;
      * ) echo -e "\nPlease answer yes or no.";;
    esac
  done
fi

while true; do
  echo ""
  read -n 1 -p "Install basic development packages? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export INSTALL_DEV_PACKAGES="true"; echo ""; break;;
    "" ) export INSTALL_DEV_PACKAGES="true"; break;;
    [Nn] ) export INSTALL_DEV_PACKAGES="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  read -n 1 -p "Install Python 3? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export INSTALL_PYTHON3="true"; echo ""; break;;
    "" ) export INSTALL_PYTHON3="true"; break;;
    [Nn] ) export INSTALL_PYTHON3="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  read -n 1 -p "Install Ansible? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy]) export INSTALL_ANSIBLE="true"; echo ""; break;;
    "" ) export INSTALL_ANSIBLE="true"; break;;
    [Nn] ) export INSTALL_ANSIBLE="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  read -n 1 -p "Install PHP? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export INSTALL_PHP="true"; echo ""; break;;
    "" ) export INSTALL_PHP="true"; break;;
    [Nn] ) export INSTALL_PHP="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  read -n 1 -p "Install NodeJS? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export INSTALL_NODEJS="true"; echo ""; break;;
    "" ) export INSTALL_NODEJS="true"; break;;
    [Nn] ) export INSTALL_NODEJS="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  read -n 1 -p "Install GOLANG? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export INSTALL_GOLANG="true"; echo ""; break;;
    "" ) export INSTALL_GOLANG="true"; break;;
    [Nn] ) export INSTALL_GOLANG="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  read -n 1 -p "Install ZSH and Oh My ZSH? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export INSTALL_ZSH="true"; echo ""; break;;
    "" ) export INSTALL_ZSH="true"; break;;
    [Nn] ) export INSTALL_ZSH="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

while true; do
  read -n 1 -p "Install Kubernetes and OpenShift binaries? [Y/n] " YNPROMPT
  case $YNPROMPT in
    [Yy] ) export INSTALL_K8S_OCP="true"; echo ""; break;;
    "" ) export INSTALL_K8S_OCP="true"; break;;
    [Nn] ) export INSTALL_K8S_OCP="false"; echo ""; break;;
    * ) echo -e "\nPlease answer yes or no.";;
  esac
done

echo ""
echo "Starting WSL distro configuration..."

echo ""
echo "--------------------------------------------------------------------------------"
echo "[BASICS]"
echo ""
echo "Installing ${INSTALL_LANGPACK} language packages..."

dnf install -qy langpacks-$INSTALL_LANGPACK glibc-langpack-$INSTALL_LANGPACK

## Do a basic system update - DONE
echo ""
echo "Updating base system..."

dnf update -yq

## Do a basic package install - DONE
echo ""
echo "Installing basic packages..."

dnf install -qy wget curl sudo ncurses dnf-plugins-core dnf-utils passwd findutils nano openssl openssh-clients procps-ng git bash-completion jq util-linux-user cracklib-dicts
dnf -yq copr enable wslutilities/wslu
dnf install -qy wslu

## Development Packages - DONE
echo ""
echo "--------------------------------------------------------------------------------"
echo "[DEV PKGS]"
if [[ $INSTALL_DEV_PACKAGES == "true" ]]; then
  echo ""
  echo "Installing Developmental Tools..."

  dnf install -yq "@Development Tools"
else
  echo ""
  echo "...SKIPPING..."
fi

echo ""
echo "--------------------------------------------------------------------------------"
echo "[PYTHON]"
if [[ $INSTALL_PYTHON3 == "true" ]]; then
  echo ""
  echo "Installing Python 3..."

  dnf install -qy python3-pip python3 python3-argcomplete
else
  echo ""
  echo "...SKIPPING..."
fi

## ZSH
echo ""
echo "--------------------------------------------------------------------------------"
echo "[ZSH]"
if [[ $INSTALL_ZSH == "true" ]]; then
  echo ""
  echo "Installing ZSH, Oh My ZSH, Powerline fonts, thefuck..."

  dnf install -qy zsh
  git clone --quiet https://github.com/powerline/fonts.git --depth=1
  cd fonts && ./install.sh && cd .. && rm -rf fonts/
  pip3 install thefuck
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  cp -R ~/.local /etc/skel
  cp -R ~/.oh-my-zsh /etc/skel
  curl -sL -o /etc/skel/.zshrc https://raw.githubusercontent.com/kenmoini/wsl-helper/main/config/zshrc
  mv ~/.zshrc ~/.zshrc-default
  cp /etc/skel/.zshrc ~/.zshrc

  echo 'export PATH=$HOME/.local/bin:$PATH' > /etc/profile.d/local_bin.sh
  chmod +x /etc/profile.d/local_bin.sh

  chsh --shell $(which zsh) $USER
else
  echo ""
  echo "...SKIPPING..."
fi

echo ""
echo "--------------------------------------------------------------------------------"
echo "[GOLANG]"
if [[ $INSTALL_GOLANG == "true" ]]; then
  echo ""
  echo "Installing GOLANG..."

  dnf install -qy golang

  echo 'export GOPATH=$HOME/go' > /etc/profile.d/golang_setup.sh
  echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /etc/profile.d/golang_setup.sh
  chmod +x /etc/profile.d/golang_setup.sh
else
  echo ""
  echo "...SKIPPING..."
fi

echo ""
echo "--------------------------------------------------------------------------------"
echo "[ANSIBLE]"
if [[ $INSTALL_ANSIBLE == "true" ]]; then
  echo ""
  echo "Installing Ansible..."

  pip3 install ansible-base
  pip3 install argcomplete
  register-python-argcomplete ansible | tee /etc/bash_completion.d/python-ansible >/dev/null
  register-python-argcomplete ansible-config | tee /etc/bash_completion.d/python-ansible-config >/dev/null
  register-python-argcomplete ansible-console | tee /etc/bash_completion.d/python-ansible-console >/dev/null
  register-python-argcomplete ansible-doc | tee /etc/bash_completion.d/python-ansible-doc >/dev/null
  register-python-argcomplete ansible-galaxy | tee /etc/bash_completion.d/python-ansible-galaxy >/dev/null
  register-python-argcomplete ansible-inventory | tee /etc/bash_completion.d/python-ansible-inventory >/dev/null
  register-python-argcomplete ansible-playbook | tee /etc/bash_completion.d/python-ansible-playbook >/dev/null
  register-python-argcomplete ansible-pull | tee /etc/bash_completion.d/python-ansible-pull >/dev/null
  register-python-argcomplete ansible-vault | tee /etc/bash_completion.d/python-ansible-vault >/dev/null

  sudo chmod +x /etc/bash_completion.d/python-a*
else
  echo ""
  echo "...SKIPPING..."
fi

echo ""
echo "--------------------------------------------------------------------------------"
echo "[PHP]"
if [[ $INSTALL_PHP == "true" ]]; then
  echo ""
  echo "Installing PHP and Composer..."

  dnf install -qy php
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php composer-setup.php
  php -r "unlink('composer-setup.php');"
  mv composer.phar /usr/local/bin/composer

  echo 'export PATH=$HOME/.composer/vendor/bin:$PATH' > /etc/profile.d/composer_bin.sh
  chmod +x /etc/profile.d/composer_bin.sh
else
  echo ""
  echo "...SKIPPING..."
fi

echo ""
echo "--------------------------------------------------------------------------------"
echo "[NODEJS]"
if [[ $INSTALL_NODEJS == "true" ]]; then
  echo ""
  echo "Installing NodeJS, NPM, and Yarn..."

  dnf install -qy nodejs npm yarnpkg

  echo 'export PATH=$HOME/.yarn/bin:$PATH' > /etc/profile.d/nodejs_bin.sh
  chmod +x /etc/profile.d/nodejs_bin.sh
else
  echo ""
  echo "...SKIPPING..."
fi

echo ""
echo "--------------------------------------------------------------------------------"
echo "[KUBERNETES]"
if [[ $INSTALL_K8S_OCP == "true" ]]; then
  echo ""
  echo "Installing K8s and OCP binaries..."

  ## Install OpenShift clients.
  curl -sL -o /tmp/oc-3.10.tar.gz https://mirror.openshift.com/pub/openshift-v3/clients/3.10.176/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-3.10.tar.gz && mv /tmp/oc /usr/local/bin/oc-3.10
  curl -sL -o /tmp/oc-3.11.tar.gz https://mirror.openshift.com/pub/openshift-v3/clients/3.11.153/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-3.11.tar.gz && mv /tmp/oc /usr/local/bin/oc-3.11
  curl -sL -o /tmp/oc-4.1.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.1/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-4.1.tar.gz && mv /tmp/oc /usr/local/bin/oc-4.1
  curl -sL -o /tmp/oc-4.2.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.2/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-4.2.tar.gz && mv /tmp/oc /usr/local/bin/oc-4.2
  curl -sL -o /tmp/oc-4.3.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.3/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-4.3.tar.gz && mv /tmp/oc /usr/local/bin/oc-4.3
  curl -sL -o /tmp/oc-4.4.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.4/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-4.4.tar.gz && mv /tmp/oc /usr/local/bin/oc-4.4
  curl -sL -o /tmp/oc-4.5.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.5/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-4.5.tar.gz && mv /tmp/oc /usr/local/bin/oc-4.5
  curl -sL -o /tmp/oc-4.6.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.6/linux/oc.tar.gz
  tar -C /tmp -zxf /tmp/oc-4.5.tar.gz && mv /tmp/oc /usr/local/bin/oc-4.6
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

  echo 'if [ -n "$BASH" ]; then' > /etc/profile.d/kubectl_completion.sh
  echo "  source <(kubectl completion bash)" >> /etc/profile.d/kubectl_completion.sh
  echo "fi" >> /etc/profile.d/kubectl_completion.sh
  chmod +x /etc/profile.d/kubectl_completion.sh

  echo 'if [ -n "$BASH" ]; then' > /etc/profile.d/oc_completion.sh
  echo "  source <(oc completion bash)" >> /etc/profile.d/oc_completion.sh
  echo "fi" >> /etc/profile.d/oc_completion.sh
  echo "alias oc='oc --insecure-skip-tls-verify'" >> /etc/profile.d/oc_completion.sh
  chmod +x /etc/profile.d/oc_completion.sh
else
  echo ""
  echo "...SKIPPING..."
fi

## Create a user - DONE
echo ""
echo "--------------------------------------------------------------------------------"
echo "[USER]"
if [[ $CREATE_USER == "true" ]]; then
  echo ""
  echo "Adding user..."
  useradd $NEW_USERNAME; echo $NEW_USER_PASSWORD | passwd $NEW_USERNAME --stdin

  if [[ $NEW_USER_TO_WHEEL == "true" ]]; then
    echo "Adding user to sudoers group 'wheel'..."
    usermod -aG wheel $NEW_USERNAME
  fi

  if [[ $INSTALL_ZSH == "true" ]]; then
    echo "Setting user shell to ZSH..."
    chsh --shell $(which zsh) $NEW_USERNAME
  fi

  echo "Setting user as default WSL user..."
  echo "[user]" > /etc/wsl.conf
  echo "default=$NEW_USERNAME" >> /etc/wsl.conf
else
  echo ""
  echo "...SKIPPING..."
fi