FROM opensuse/tumbleweed as qt

COPY ./image/ /tmp/

RUN \
  # Setup image entrypoint
  cp /tmp/entrypoint.sh / && \
  chmod +x /entrypoint.sh && \
  \
  # Setup repositories
  rm -f /etc/zypp/repos.d/* && \
  \
  zypper addrepo -f "http://download.opensuse.org/tumbleweed/repo/oss/" "OSS" && \
  zypper addrepo -f "http://download.opensuse.org/tumbleweed/repo/src-oss/" "Src-OSS" && \
  zypper addrepo -f -p 1 "obs://KDE:Unstable:Qt/openSUSE_Tumbleweed/" "KDE:Unstable:Qt" && \
  zypper addrepo -f -p 1 "obs://KDE:Unstable:Frameworks/openSUSE_Factory/" "KDE:Unstable:Frameworks" && \
  zypper addrepo -f -p 1 "obs://KDE:Unstable:Applications/KDE_Unstable_Frameworks_openSUSE_Factory/" "KDE:Unstable:Applications" && \
  \
  # Refresh all repositories
  zypper -n --gpg-auto-import-keys refresh && \
  \
  # Install and configure fonts
  zypper -n install --no-recommends \
    fontconfig \
    noto-sans-fonts \
    adobe-sourcecodepro-fonts && \
  \
  cp /tmp/etc/fonts/local.conf /etc/fonts/local.conf && \
  fc-cache && \
  \
  # Install system utilities
  zypper -n install --no-recommends \
    sudo \
    util-linux \
    vim \
    which \
    xterm && \
  \
  # Install dev tools
  zypper -n install --no-recommends \
    arcanist \
    ccache \
    gdb \
    git \
    kcachegrind \
    kdbg && \
  \
  # Install Qt
  zypper -n install --recommends -t pattern devel_qt5 && \
  \
  # Create default user
  useradd -m -g users dev && \
  echo 'dev ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/dev && \
  \
  # Configure Git URL prefixes for KDE repositories
  su -c 'git config --global url."https://anongit.kde.org/".insteadOf kde:' - dev && \
  su -c 'git config --global url."git@git.kde.org:".pushInsteadOf kde:' - dev && \
  \
  # Create XDG runtime dir
  mkdir -p /run/dev && \
  chmod 0700 /run/dev && \
  chown dev:users /run/dev && \
  \
  # Install kdesrc-build dependencies
  zypper -n install --no-recommends \
    dialog \
    perl-IO-Socket-SSL \
    perl-JSON-XS \
    perl-YAML-Syck && \
  \
  # Create kdesrc-build workdir
  su -c 'mkdir -p ~/kde' - dev && \
  \
  # Install kdesrc-build
  su -c 'git clone --depth=1 kde:kdesrc-build ~/.kdesrc-build' - dev && \
  su -c 'mkdir -p ~/bin' - dev && \
  su -c 'ln -sf ~/.kdesrc-build/kdesrc-build ~/bin/kdesrc-build' - dev && \
  su -c 'ln -sf ~/.kdesrc-build/kdesrc-build-setup ~/bin/kdesrc-build-setup' - dev && \
  \
  # Configure kdesrc-build
  su -c 'cp /tmp/home/dev/kdesrc-buildrc ~/.kdesrc-buildrc' - dev && \
  \
  # Cleanup
  zypper clean -a && \
  rm -rf /tmp/*

ENV \
  HOME=/home/dev \
  QT=/usr/lib64/qt5

ENV \
  DISPLAY=:0 \
  \
  PATH=$HOME/bin:$QT/bin:$PATH \
  \
  QML_IMPORT_PATH=$QT/qml \
  QML2_IMPORT_PATH=$QT/qml \
  QT_PLUGIN_PATH=$QT/plugins \
  \
  XDG_DATA_DIRS=/usr/share \
  XDG_CONFIG_DIRS=/etc/xdg \
  XDG_RUNTIME_DIR=/run/dev

VOLUME \
  $HOME/.config \
  $HOME/kde

USER dev
WORKDIR $HOME

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]


FROM qt as kde-frameworks

RUN \
  sudo zypper -n install --recommends -t pattern devel_kde_frameworks && \
  sudo zypper clean -a


FROM kde-frameworks as plasma-desktop

RUN \
  sudo zypper -n install -t pattern kde_plasma && \
  sudo zypper -n install --no-recommends dolphin