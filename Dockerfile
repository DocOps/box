ARG BASE_IMAGE=ruby
ARG RUBY_VERSION=3.3
ARG DISTRO=slim-bookworm
ARG DELIM=-

FROM $BASE_IMAGE:${RUBY_VERSION}${DELIM}${DISTRO}

# This Dockerfile builds TWO distinct images with some variation:
# The "work" IMAGE_CONTEXT is for a development/authoring environment (default).
# The "live" IMAGE_CONTEXT is for a staging, testing, or production environment.
# Adding NodeJS and/or Python is optional in both contexts.
# Zshell is installed only in the "work" context.
# Git is installed and can perform clone operations on public repos.
# Only in the work context, with user consent, is Git set up with name/email/SSH.
# For the "live" context, SSH keys should be mounted as a secret volume and/or
#  handled in a post-build script.

# Set remaining build arguments
ARG PRE_BUILD_SCRIPT_ARGS=""
ARG POST_BUILD_SCRIPT_ARGS=""
ARG IMAGE_CONTEXT="work"
ARG GIT_NAME
ARG GIT_EMAIL
ARG ADD_NODEJS=true
ARG ADD_PYTHON=true
ARG ADD_PANDOC=true
ARG ADD_OPENAPI_TOOLS=true
ARG ADD_VALE=true
ARG ADD_LIBREOFFICE=false
ARG RUN_USER="appuser"
ARG HOST_UID=1000
ARG HOST_GID=1000
ARG RUBY_VERSION
ARG NODEJS_VERSION="24"
ARG VALE_VERSION="3.14.1"
ARG YQ_VERSION="4.53.2"
ARG BAT_VERSION="0.26.1"
ARG SPEAKEASY_VERSION="1.761.9"
ARG TARGETARCH
ARG WORKDIR="/workspace"
ARG DEFAULT_EDITOR="nano"
ARG DOCOPSBOX_VERSION="0.1.0"

LABEL version=$DOCOPSBOX_VERSION \
    IMAGE_CONTEXT=$IMAGE_CONTEXT \
    NODEJS=$ADD_NODEJS \
    PYTHON=$ADD_PYTHON \
    OPENAPI_TOOLS=$ADD_OPENAPI_TOOLS \
    PANDOC=$ADD_PANDOC \
    LIBREOFFICE=$ADD_LIBREOFFICE \
    RUBY_VERSION=$RUBY_VERSION \
    NODEJS_VERSION=$NODEJS_VERSION \
    WORKDIR=$WORKDIR \
    RUN_USER=$RUN_USER

ENV DOCOPSBOX_VERSION=$DOCOPSBOX_VERSION \
    BUNDLE_PATH=/usr/local/bundle \
    GEM_HOME=/usr/local/bundle \
    GEM_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:/usr/local/bundle/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive \
    DEFAULT_EDITOR=$DEFAULT_EDITOR \
    npm_config_cache=/npm-cache \
    PIP_CACHE_DIR=/pip-cache \
    HISTFILE=/commandhistory/.zsh_history \
    HISTSIZE=10000 \
    SAVEHIST=10000 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    ARCH=$TARGETARCH \
    DOCOPS_WELCOME_COMMANDS="echo 'Welcome to DocOps Box. Happy operating!'"

SHELL ["/bin/bash", "-c"]

# HOOK: optional pre-build script
# If dockerfile-hooks/pre-build.sh exists, it runs as root.
RUN --mount=type=bind,source=hooks/early,target=/ctx/hooks \
    if [ -f /ctx/hooks/pre-build.sh ]; then \
      cp /ctx/hooks/pre-build.sh /tmp/build-script-pre.sh && \
      chmod +x /tmp/build-script-pre.sh && \
      /tmp/build-script-pre.sh ${PRE_BUILD_SCRIPT_ARGS} \
  ; else \
      echo "No pre-build hook found; skipping" \
  ; fi

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    curl \
    wget \
    openssh-client \
    build-essential \
    findutils \
    unzip \
    git \
    gosu \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN if [ "$IMAGE_CONTEXT" = "work" ] ; then \
      # Install prerequisites for GitHub CLI
      mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d \
      && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
           -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      && echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
           > /etc/apt/sources.list.d/github-cli.list \
      # APT packages
      && apt-get update && apt-get install -y --no-install-recommends \
      gnupg \
      zsh \
      nano \
      vim \
      sudo \
      inotify-tools \
      iputils-ping \
      tzdata \
      fonts-dejavu \
      gh \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      # Install yq
      && curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH}" -o /usr/local/bin/yq \
      && chmod +x /usr/local/bin/yq \
      # Install bat (bat uses GNU arch names in its release filenames)
      && BAT_ARCH=$([ "$ARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") \
      && curl -fsSL "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl.tar.gz" \
         -o /tmp/bat.tar.gz \
      && tar -xzf /tmp/bat.tar.gz -C /tmp \
      && mv /tmp/bat-v${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl/bat /usr/local/bin/bat \
      && chmod +x /usr/local/bin/bat \
      && rm -rf /tmp/bat.tar.gz /tmp/bat-v${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl \
    else \
      echo "Extra utilities skipped" \
  ; fi

RUN if [ "$ADD_PYTHON" = "true" ] || [ "$ADD_LIBREOFFICE" = "true" ]; then \
      apt-get update && apt-get install -y python3 python3-pip python3-venv \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "Python skipped" \
  ; fi

RUN if [ "$ADD_LIBREOFFICE" = "true" ]; then \
      apt-get update && apt-get install -y --no-install-recommends \
      libreoffice-core libreoffice-common libreoffice-writer libreoffice-calc \
      python3-uno \
      && pip3 install --break-system-packages unoserver \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "LibreOffice skipped" \
  ; fi

RUN if [ "$ADD_PANDOC" = "true" ]; then \
      apt-get update && apt-get install -y --no-install-recommends \
      pandoc \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "Pandoc skipped" \
  ; fi

RUN if [ "$ADD_NODEJS" = "true" ] || [ "$ADD_OPENAPI_TOOLS" = "true" ]; then \
      curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash - \
      && apt-get install -y nodejs \
      && npm install -g yarn \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "Node.js skipped" \
  ; fi

RUN if [ "$ADD_VALE" = "true" ]; then \
      VALE_ARCH=$([ "$ARCH" = "arm64" ] && echo "Linux_arm64" || echo "Linux_64-bit") \
      && curl -fsSL "https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_${VALE_ARCH}.tar.gz" \
           -o /tmp/vale.tar.gz \
      && mkdir -p /usr/local/bin \
      && tar -xzf /tmp/vale.tar.gz -C /usr/local/bin \
      && rm /tmp/vale.tar.gz \
  ; else \
      echo "Vale skipped" \
  ; fi

# Add redocly-cli, vacuum, and speakeasy
RUN if [ "$ADD_OPENAPI_TOOLS" = "true" ]; then \
      curl -fsSL "https://github.com/speakeasy-api/speakeasy/releases/download/v${SPEAKEASY_VERSION}/speakeasy_linux_${ARCH}.zip" \
           -o /tmp/speakeasy.zip \
      && unzip /tmp/speakeasy.zip speakeasy -d /usr/local/bin \
      && chmod +x /usr/local/bin/speakeasy \
      && rm /tmp/speakeasy.zip \
      && npm cache clean --force \
      && npm install -g @redocly/cli @quobix/vacuum \
  ; fi

RUN groupadd --gid $HOST_GID $RUN_USER \
    && useradd --uid $HOST_UID --gid $HOST_GID --create-home --shell /bin/bash $RUN_USER

# Create directories the runtime user must own
RUN mkdir -p /usr/local/bundle /commandhistory /npm-cache /pip-cache /opt/venv $WORKDIR/node_modules $WORKDIR \
    && chown -R $HOST_UID:$HOST_GID /usr/local/bundle /commandhistory /npm-cache /pip-cache /opt/venv $WORKDIR

# Pre-create the SSH directory with correct permissions as root, so the user
# can use SSH keys mounted at runtime without needing sudo.
RUN if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then \
      mkdir -p /home/$RUN_USER/.ssh \
      && chmod 700 /home/$RUN_USER/.ssh \
      && chown -R $RUN_USER:$RUN_USER /home/$RUN_USER/.ssh \
  ; fi

# Configure Zsh as the default shell and grant passwordless sudo for work context.
# chsh must run as root and requires the user to already exist (created above)
# and zsh to be installed (installed in the work-context packages block above).
RUN if [ "$IMAGE_CONTEXT" = "work" ]; then \
      chsh -s /bin/zsh $RUN_USER \
      && echo "$RUN_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$RUN_USER \
      && chmod 0440 /etc/sudoers.d/$RUN_USER \
  ; fi

# Switch to the non-root user for all remaining steps
USER $RUN_USER

# Configure Git global settings
RUN if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then \
      git config --global user.name "$GIT_NAME" && \
      git config --global user.email "$GIT_EMAIL" \
    else \
      git config --global --add safe.directory $WORKDIR \
  ; fi

# Install Oh My Zsh and configure Zsh for interactive work context.
# templates/.zshrc is the canonical source; edit it to customize the shell.
# AsciiDoc include tags in that file allow sections to be transcluded into docs.
COPY templates/.zshrc /tmp/docops-zshrc
RUN if [ "$IMAGE_CONTEXT" = "work" ]; then \
      RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
      && git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
      && cp /tmp/docops-zshrc /home/$RUN_USER/.zshrc \
      && printf 'set linenumbers\nset mouse\nset tabsize 2\nset softwrap\n' > /home/$RUN_USER/.nanorc \
      && printf 'syntax on\nfiletype plugin indent on\nset number\n' > /home/$RUN_USER/.vimrc \
      && gem install asciidoctor-pdf nokogiri tilt kramdown-asciidoc html-proofer \
      && git config --global init.defaultBranch main \
      && git config --global pull.rebase false \
      && git config --global push.autoSetupRemote true \
      && git config --global core.pager cat \
  ; fi

# Optionally copy project dependency manifests so a post-build script can run
# bundle/npm/pip install inside the image. All three are optional — if absent
# from the build context, this step is a no-op. Users who want to pre-bake
# dependencies place their Gemfile, package.json, or requirements.txt at the
# project root when running `docker build`.
RUN --mount=type=bind,source=.,target=/ctx \
    for f in Gemfile Gemfile.lock package.json requirements.txt; do \
        [ -f /ctx/$f ] && cp /ctx/$f $WORKDIR/$f || true; \
    done \
    && chown -R ${HOST_UID}:${HOST_GID} $WORKDIR 2>/dev/null || true

USER root

# HOOK: optional post-build script
# If hooks/post-build.sh exists, it runs as root.
RUN --mount=type=bind,source=hooks/late,target=/ctx/hooks \
    if [ -f /ctx/hooks/post-build.sh ]; then \
      cp /ctx/hooks/post-build.sh /tmp/build-script-post.sh && \
      chmod +x /tmp/build-script-post.sh && \
      /tmp/build-script-post.sh ${POST_BUILD_SCRIPT_ARGS} \
    else \
      echo "No post-build hook found; skipping" \
  ; fi

COPY hooks/late/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY hooks/late/docops /usr/local/bin/docops
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/docops

WORKDIR $WORKDIR

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD [ "bash" ]