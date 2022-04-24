#!/bin/bash

CREATE_USER="true"
NEW_USERNAME="wsluser"
NEW_USER_PASSWORD="somePassw0rd"
NEW_USER_TO_WHEEL="true"

INSTALL_ZSH="true"
INSTALL_GOLANG="true"
INSTALL_PYTHON="true"
INSTALL_PHP="true"
INSTALL_NODEJS="true"
INSTALL_ANSIBLE="true"
INSTALL_OCP_BINARIES="true"
INSTALL_PODMAN="true"

## Install language packs
echo "===== Installing language packs..."
dnf install -yq langpacks-en glibc-langpack-en

## Do basic updates
echo "===== Installing system updates..."
dnf update -yq

## Install basic useful packages
echo "===== Installing basic packages..."
dnf install -yq wget curl sudo ncurses dnf-plugins-core dnf-utils passwd findutils nano openssl openssh-clients procps-ng git bash-completion jq util-linux-user cracklib-dicts

## Install development tools
echo "===== Installing Developmental Tools..."
dnf install -yq autoconf automake gcc gcc-c++ gdb glibc-devel libtool make pkgconf pkgconf-m4 pkgconf-pkg-config redhat-rpm-config rpm-build ncurses-devel

## Install Python
if [ "$INSTALL_PYTHON" = "true" ]; then
  echo "===== Installing Python..."
  dnf install -yq python38-pip python38
fi

## Install ZSH
if [ "$INSTALL_ZSH" = "true" ]; then
  if [ ! -f "/usr/local/bin/zsh" ]; then
    echo "===== Installing ZSH..."
    curl -sSL -o /tmp/zsh.tar.xz https://phoenixnap.dl.sourceforge.net/project/zsh/zsh/5.8.1/zsh-5.8.1.tar.xz
    cd /tmp && tar xvf zsh.tar.xz
    rm zsh.tar.xz
    cd zsh-5.8.1
    ./configure
    make
    make install
    ln -s /usr/local/bin/zsh /bin/zsh
    echo "/bin/zsh" >> /etc/shells
    echo "/usr/local/bin/zsh" >> /etc/shells
  fi
fi

## Install Golang
if [ "$INSTALL_GOLANG" = "true" ]; then
  echo "===== Installing Golang..."
  dnf install -yq golang
  echo 'export GOPATH=$HOME/go' > /etc/profile.d/golang_setup.sh
  echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> /etc/profile.d/golang_setup.sh
  chmod a+rx /etc/profile.d/golang_setup.sh
  cp /etc/profile.d/golang_setup.sh /etc/profile.d/golang_setup.zsh
fi

## Install Ansible
if [ "$INSTALL_ANSIBLE" = "true" ]; then
  echo "===== Installing Ansible..."
  python3 -m pip -q install ansible-base argcomplete
  register-python-argcomplete ansible-config | tee /etc/bash_completion.d/python-ansible-config >/dev/null
  register-python-argcomplete ansible-console | tee /etc/bash_completion.d/python-ansible-console >/dev/null
  register-python-argcomplete ansible-doc | tee /etc/bash_completion.d/python-ansible-doc >/dev/null
  register-python-argcomplete ansible-galaxy | tee /etc/bash_completion.d/python-ansible-galaxy >/dev/null
  register-python-argcomplete ansible-inventory | tee /etc/bash_completion.d/python-ansible-inventory >/dev/null
  register-python-argcomplete ansible-playbook | tee /etc/bash_completion.d/python-ansible-playbook >/dev/null
  register-python-argcomplete ansible-pull | tee /etc/bash_completion.d/python-ansible-pull >/dev/null
  register-python-argcomplete ansible-vault | tee /etc/bash_completion.d/python-ansible-vault >/dev/null
  chmod a+rx /etc/bash_completion.d/python-a*
fi

## Install PHP
if [ "$INSTALL_PHP" = "true" ]; then
  echo "===== Installing PHP..."
  dnf install -yq php php-bcmath php-cli php-devel php-gd php-intl php-json php-mbstring php-pdo php-pear php-process php-xml php-xmlrpc
  if [ ! -f "/usr/local/bin/composer" ]; then
    echo "===== Installing Composer for PHP..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/local/bin/composer
    
    echo 'export PATH=$HOME/.composer/vendor/bin:$PATH' > /etc/profile.d/composer_bin.sh
    chmod a+rx /etc/profile.d/composer_bin.sh
    cp /etc/profile.d/composer_bin.sh /etc/profile.d/composer_bin.zsh
  fi
fi

## Install NodeJS
if [ "$INSTALL_NODEJS" = "true" ]; then
  echo "===== Installing NodeJS..."
  dnf install -yq nodejs npm
fi

## Install Podman
if [ "$INSTALL_PODMAN" = "true" ]; then
  echo "===== Installing Podman..."
  dnf install -yq podman skopeo buildah crun slirp4netns fuse-overlayfs containernetworking-plugins iputils iproute
  
  chmod 4755 /usr/bin/newgidmap
  chmod 4755 /usr/bin/newuidmap
  
  dnf reinstall -yq shadow-utils
  
  cat > /etc/profile.d/xdg_runtime_dir.sh <<EOF
export XDG_RUNTIME_DIR="\$HOME/.run/containers"
EOF
  chmod a+rx /etc/profile.d/xdg_runtime_dir.sh
  cp /etc/profile.d/xdg_runtime_dir.sh /etc/profile.d/xdg_runtime_dir.zsh
  
  cat > /etc/sysctl.d/ping_group_range.conf <<EOF
net.ipv4.ping_group_range=0 2000000
EOF
  
  cat > /etc/sysctl.d/ping_group_range.conf <<EOF
net.ipv4.ping_group_range=0 2000000
EOF

  cat > /etc/containers/containers.conf <<EOF
[containers]
default_capabilities = [
  "NET_RAW",
  "CHOWN",
  "DAC_OVERRIDE",
  "FOWNER",
  "FSETID",
  "KILL",
  "NET_BIND_SERVICE",
  "SETFCAP",
  "SETGID",
  "SETPCAP",
  "SETUID",
  "SYS_CHROOT"
]

default_sysctls = [
  "net.ipv4.ping_group_range=0 0",
]

log_driver = "k8s-file"

rootless_networking = "slirp4netns"

[secrets]

[network]

[engine]
cgroup_manager = "cgroupfs"
events_logger = "file"
infra_image = "registry.access.redhat.com/ubi8/pause"
runtime = "crun"
runtime_supports_json = ["crun", "runc", "kata", "runsc"]

[engine.runtimes]

[engine.volume_plugins]

[machine]

EOF

  cat > /etc/containers/storage.conf <<EOF
[storage]
driver = "overlay"
runroot = "/run/containers/storage"
graphroot = "/var/lib/containers/storage"
rootless_storage_path = "\$HOME/.local/share/containers/storage"

[storage.options]
mount_program = "/usr/bin/fuse-overlayfs"
additionalimagestores = [
]

[storage.options.overlay]
mountopt = "nodev,metacopy=on"

[storage.options.thinpool]
EOF
fi

## Install OpenShift binaries
if [ "$INSTALL_OCP_BINARIES" = "true" ]; then
  if [ ! -f "/usr/local/bin/kubectl" ]; then
    echo "===== Installing kubectl and oc..."
    curl -sSL -o /tmp/oc-4.10.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.10/openshift-client-linux.tar.gz
    tar -C /tmp -zxf /tmp/oc-4.10.tar.gz
    mv /tmp/oc /usr/local/bin/oc
    mv /tmp/kubectl /usr/local/bin/kubectl
    rm /tmp/oc*.tar.gz

    chmod a+rx /usr/local/bin/kubectl
    chmod a+rx /usr/local/bin/oc

    echo 'if [ -n "$BASH" ]; then' > /etc/profile.d/kubectl_completion.sh
    echo "  source <(/usr/local/bin/kubectl completion bash)" >> /etc/profile.d/kubectl_completion.sh
    echo "fi" >> /etc/profile.d/kubectl_completion.sh
    echo "source <(/usr/local/bin/kubectl completion zsh)" >> /etc/profile.d/kubectl_completion.zsh
    chmod a+rx /etc/profile.d/kubectl_completion.sh
    chmod a+rx /etc/profile.d/kubectl_completion.zsh

    echo 'if [ -n "$BASH" ]; then' > /etc/profile.d/oc_completion.sh
    echo "  source <(/usr/local/bin/oc completion bash)" >> /etc/profile.d/oc_completion.sh
    echo "fi" >> /etc/profile.d/oc_completion.sh
    echo "source <(/usr/local/bin/oc completion zsh)" > /etc/profile.d/oc_completion.zsh
    echo "alias oc='oc --insecure-skip-tls-verify'" >> /etc/profile.d/oc_completion.sh
    echo "alias oc='oc --insecure-skip-tls-verify'" >> /etc/profile.d/oc_completion.zsh
    chmod a+rx /etc/profile.d/oc_completion.sh
    chmod a+rx /etc/profile.d/oc_completion.zsh
  fi

  if [ ! -f "/usr/local/bin/odo" ]; then
    echo "===== Installing odo..."
    curl -sSL -o /usr/local/bin/odo https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/odo/v2.5.1/odo-linux-amd64
    chmod a+rx /usr/local/bin/odo
  fi
fi

## Create a User
if [ "$CREATE_USER" = "true" ]; then
  echo "Creating the user ${NEW_USERNAME}..."
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
  
  if [ "$INSTALL_PODMAN" = "true" ]; then
    mkdir -p /run/user/$(id -u $NEW_USERNAME)
    chown ${NEW_USERNAME}:${NEW_USERNAME} /run/user/$(id -u $NEW_USERNAME)

    usermod --add-subuids 200000-201000 --add-subgids 200000-201000 $NEW_USERNAME

    mkdir -p /home/${NEW_USERNAME}/.config/containers
    mkdir -p /home/${NEW_USERNAME}/.run/containers
    cat > /home/${NEW_USERNAME}/.config/containers/storage.conf << EOF
[storage]
  driver = "overlay"
  runroot = "/home/${NEW_USERNAME}/.run/containers"
  graphroot = "/home/${NEW_USERNAME}/.local/share/containers/storage"
  [storage.options]
    size = ""
    remap-uids = ""
    remap-gids = ""
    ignore_chown_errors = ""
    remap-user = ""
    remap-group = ""
    skip_mount_home = ""
    mount_program = "/usr/bin/fuse-overlayfs"
    mountopt = ""
    [storage.options.aufs]
      mountopt = ""
    [storage.options.btrfs]
      min_space = ""
      size = ""
    [storage.options.thinpool]
      autoextend_percent = ""
      autoextend_threshold = ""
      basesize = ""
      blocksize = ""
      directlvm_device = ""
      directlvm_device_force = ""
      fs = ""
      log_level = ""
      min_free_space = ""
      mkfsarg = ""
      mountopt = ""
      size = ""
      use_deferred_deletion = ""
      use_deferred_removal = ""
      xfs_nospace_max_retries = ""
    [storage.options.overlay]
      ignore_chown_errors = ""
      mountopt = ""
      mount_program = ""
      size = ""
      skip_mount_home = ""
    [storage.options.vfs]
      ignore_chown_errors = ""
    [storage.options.zfs]
      mountopt = ""
      fsname = ""
      size = ""
EOF
fi

cat > /home/${NEW_USERNAME}/zsh_setup.sh <<"EOB"
#/bin/bash

## Install OMZ
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv $HOME/.zshrc $HOME/.zshrc.omz

cat > $HOME/.zshrc <<EOF
export ZSH="\$HOME/.oh-my-zsh"
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
plugins=(git)
source \$ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export EDITOR="nano"

autoload -Uz compinit
compinit
source /etc/zprofile
EOF
EOB

cat > /home/${NEW_USERNAME}/.zshrc <<EOF
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

autoload -Uz compinit
compinit

source /etc/zprofile

EOF

cat > /etc/zprofile <<EOF
#!/bin/zsh

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.zsh; do
    if [ -r \$i ]; then
      . \$i
    fi
  done
  unset i
fi

if [ ! -d "\$HOME/.oh-my-zsh" ]; then
  echo "Oh My ZSH has not been setup yet!  Run ~/zsh_setup.sh"
fi

EOF

  chmod a+x /etc/zprofile

  chmod +x /home/${NEW_USERNAME}/zsh_setup.sh
  chown -R ${NEW_USERNAME}:${NEW_USERNAME} /home/${NEW_USERNAME}/
fi

echo 'export PATH="/usr/local/bin:$PATH"' > /etc/profile.d/usr_local_bin.sh
chmod a+rx /etc/profile.d/usr_local_bin.sh
cp /etc/profile.d/usr_local_bin.sh /etc/profile.d/usr_local_bin.zsh
