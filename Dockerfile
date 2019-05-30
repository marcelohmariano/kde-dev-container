FROM opensuse/tumbleweed

COPY ./image/ /tmp/

RUN echo 'Building image...' \
  \
  # Setup image entrypoint
  && cp /tmp/entrypoint.sh / \
  && chmod +x /entrypoint.sh \
  \
  && rm -f /etc/zypp/repos.d/* \
  \
  # Add repositories
  && zypper addrepo --refresh "http://download.opensuse.org/tumbleweed/repo/oss/" "OSS" \
  && zypper addrepo --refresh "http://download.opensuse.org/tumbleweed/repo/src-oss/" "Src-OSS" \
  && zypper addrepo --refresh "obs://devel:tools:scm/openSUSE_Tumbleweed/" "Devel:Tools:SCM" \
  && zypper addrepo --refresh --priority 1 "obs://KDE:Unstable:Qt/openSUSE_Tumbleweed/" "KDE:Unstable:Qt" \
  && zypper addrepo --refresh --priority 1 "obs://KDE:Unstable:Frameworks/openSUSE_Factory/" "KDE:Unstable:Frameworks" \
  && zypper addrepo --refresh --priority 1 "obs://KDE:Unstable:Applications/KDE_Unstable_Frameworks_openSUSE_Factory/" "KDE:Unstable:Applications" \
  \
  # Refresh all repositories
  && zypper -n --gpg-auto-import-keys refresh \
  \
  # Install some utilities
  && zypper -n install --no-recommends sudo vim which xterm \
  \
  # Install development packages
  && zypper -n install --recommends -t pattern devel_kde_frameworks \
  \
  # Install fonts
  && zypper -n install --no-recommends \
    noto-sans-fonts \
    adobe-sourcecodepro-fonts \
  \
  # Install dev tools
  && zypper -n install --no-recommends \
    arcanist \
    ccache \
    gdb \
    kcachegrind \
    kdbg \
  \
  # Install kdesrc-build dependencies
  && zypper -n install --no-recommends \
    dialog \
    perl-JSON-XS \
    perl-YAML-Syck \
  \
  # Create user
  && useradd -m -g users dev \
  && echo 'dev ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/dev \
  \
  # Create XDG_RUNTIME_DIR
  && mkdir -p /run/dev \
  && chmod 0700 /run/dev \
  && chown dev:users /run/dev \
  \
  # Configure Git URL prefixes for KDE repositories
  && su -c 'git config --global url."https://anongit.kde.org/".insteadOf kde:' - dev \
  && su -c 'git config --global url."git@git.kde.org:".pushInsteadOf kde:' - dev \
  \
  # Configure fonts
  && cp /tmp/etc/fonts/local.conf /etc/fonts/local.conf \
  && fc-cache \
  \
  # Create kdesrc-build workdir
  && su -c 'mkdir -p ~/kde' - dev \
  \
  # Install kdesrc-build
  && su -c 'git clone --depth=1 kde:kdesrc-build ~/kdesrc-build' - dev \
  && su -c 'mkdir -p ~/bin' - dev \
  && su -c 'ln -sf ~/kdesrc-build/kdesrc-build ~/bin/kdesrc-build' - dev \
  && su -c 'ln -sf ~/kdesrc-build/kdesrc-build-setup ~/bin/kdesrc-build-setup' - dev \
  \
  # Configure kdesrc-build
  && su -c 'cp /tmp/home/dev/kdesrc-buildrc ~/.kdesrc-buildrc' - dev \
  \
  # Cleanup
  && zypper clean -a \
  && rm -rf /tmp/*

ENV \
  HOME=/home/dev \
  QT5=/usr/lib64/qt5

ENV \
  DISPLAY=:0 \
  \
  PATH=$HOME/bin:$QT5/bin:$PATH \
  \
  QML_IMPORT_PATH=$QT5/qml \
  QML2_IMPORT_PATH=$QT5/qml \
  QT_PLUGIN_PATH=$QT5/plugins  \
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