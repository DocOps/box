ARG BASE_IMAGE=ruby
ARG RUBY_VERSION=3.2
ARG DISTRO=slim-bullseye
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
# No public images exist for this Dockerfile as it is user-context dependent.

# Set remaining build arguments
ARG DOCKERFILE_DIR="."
ARG BUILD_SCRIPT_PRE="dockerfile-pre-build.sh"
ARG BUILD_SCRIPT_POST="dockerfile-post-build.sh"
ARG PRE_BUILD_SCRIPT_ARGS=""
ARG POST_BUILD_SCRIPT_ARGS=""
ARG IMAGE_CONTEXT="work"
ARG GIT_NAME
ARG GIT_EMAIL
ARG ADD_NODEJS=true
ARG ADD_PYTHON=true
ARG ADD_PANDOC=true
ARG ADD_REDOCLY=true
ARG ADD_VALE=true
ARG ADD_LIBREOFFICE=false
ARG RUN_USER="appuser"
ARG HOST_UID=1000
ARG HOST_GID=1000
# Re-declare RUBY_VERSION here so it is available after FROM (pre-FROM ARGs are reset).
ARG RUBY_VERSION
ARG NODEJS_VERSION="24"
# PYTHON_VERSION is not declared here: the apt packages python3/python3-pip do not
# support pinning to a specific minor version. Use a custom downstream image (FROM
# docopslab/box-max:work) with pyenv or deadsnakes PPA if you need a pinned version.
ARG REDOCLY_VERSION="latest"
ARG VALE_VERSION="3.13.0"
ARG WORKDIR="/workspace"
ARG DEFAULT_EDITOR="nano"

LABEL version="0.1.0" \
    IMAGE_CONTEXT=$IMAGE_CONTEXT \
    NODEJS=$ADD_NODEJS \
    PYTHON=$ADD_PYTHON \
    REDOCLY=$ADD_REDOCLY \
    PANDOC=$ADD_PANDOC \
    RUBY_VERSION=$RUBY_VERSION \
    NODEJS_VERSION=$NODEJS_VERSION \
    WORKDIR=$WORKDIR \
    RUN_USER=$RUN_USER

ENV BUNDLE_PATH=/usr/local/bundle \
    GEM_HOME=/usr/local/bundle \
    GEM_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    PATH=/usr/local/bundle/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive \
    DEFAULT_EDITOR=$DEFAULT_EDITOR \
    # Redirect npm and pip download caches to fixed paths independent of $HOME.
    # These are mounted as named volumes in compose.yml so downloaded packages
    # survive container teardown and are shared across all projects on the host.
    # npm_config_cache is lowercase by npm convention (maps to `npm config set cache`).
    # PIP_CACHE_DIR is uppercase by pip convention. Both are correct for their tools.
    npm_config_cache=/npm-cache \
    PIP_CACHE_DIR=/pip-cache \
    # Redirect Zsh history to the shared named volume so it persists across
    # container restarts and is backed up by `docopsbox backup-history`.
    HISTFILE=/commandhistory/.zsh_history \
    HISTSIZE=10000 \
    SAVEHIST=10000

# Use bash for all RUN instructions — Debian-based Ruby images ship with bash,
# and several conditional blocks use [[ ]] and other bash-specific syntax.
SHELL ["/bin/bash", "-c"]

# HOOK for custom pre-build operations.
# dockerfile-pre-build.sh is a placeholder by default (runs as a no-op).
# Replace it with real commands to customize the build before packages are installed.
# IMPORTANT: this file must exist in the build context — Docker COPY has no
# "if exists" conditional. The placeholder file in this repo satisfies that requirement.
COPY $BUILD_SCRIPT_PRE $WORKDIR/build-script-pre.sh
RUN chmod +x $WORKDIR/build-script-pre.sh \
    && $WORKDIR/build-script-pre.sh $PRE_BUILD_SCRIPT_ARGS

# Install core packages (gosu is required by entrypoint.sh for safe privilege drop)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    curl \
    wget \
    openssh-client \
    build-essential \
    findutils \
    git \
    gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install additional packages/tools for the "work" image
RUN if [ "$IMAGE_CONTEXT" = "work" ] ; then \
      apt-get update && apt-get install -y --no-install-recommends \
      gnupg \
      zsh \
      nano \
      sudo \
      inotify-tools \
      tzdata \
      fonts-dejavu \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "Extra utilities skipped" \
  ; fi

RUN if [ "$ADD_LIBREOFFICE" = "true" ]; then \
      apt-get update && apt-get install -y --no-install-recommends \
      libreoffice-core libreoffice-common libreoffice-writer libreoffice-calc unoconv \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "LibreOffice skipped" \
  ; fi

# Conditionally install Pandoc
RUN if [ "$ADD_PANDOC" = "true" ]; then \
      apt-get update && apt-get install -y --no-install-recommends \
      pandoc \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "Pandoc skipped" \
  ; fi

# Conditionally install Node.js
RUN if [ "$ADD_NODEJS" = "true" ]; then \
      curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash - \
      && apt-get update && apt-get install -y nodejs \
      && npm install -g yarn \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "Node.js skipped" \
  ; fi

# Conditionally install Python
RUN if [ "$ADD_PYTHON" = "true" ]; then \
      apt-get update && apt-get install -y python3 python3-pip \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
    else \
      echo "Python skipped" \
    ; fi

# Optionally install Vale
RUN if [ "$ADD_VALE" = "true" ]; then \
      cd /tmp \
      && wget "https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz" \
      && mkdir -p /usr/local/bin \
      && tar -xzf "vale_${VALE_VERSION}_Linux_64-bit.tar.gz" -C /usr/local/bin \
      && rm "vale_${VALE_VERSION}_Linux_64-bit.tar.gz"; \
    else \
      echo "Vale skipped" \
    ; fi

# Create the non-root runtime user with host-matching UID/GID for transparent
# file ownership. HOST_UID and HOST_GID are passed in by compose.yml.
RUN groupadd --gid $HOST_GID $RUN_USER \
    && useradd --uid $HOST_UID --gid $HOST_GID --create-home --shell /bin/bash $RUN_USER

# Create directories the runtime user must own: gem bundle cache, shell history
# volume mount point, npm cache, pip cache, and workspace. Done as root.
RUN mkdir -p /usr/local/bundle /commandhistory /npm-cache /pip-cache $WORKDIR \
    && chown -R $HOST_UID:$HOST_GID /usr/local/bundle /commandhistory /npm-cache /pip-cache $WORKDIR

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

# Optionally install Redocly CLI (requires Node.js; runs as $RUN_USER via npm -g)
RUN if [ "$ADD_REDOCLY" = "true" ] && [ "$ADD_NODEJS" = "true" ]; then \
      npm cache clean --force \
      && npm install @redocly/openapi-cli@$REDOCLY_VERSION -g \
    else \
      echo "Redocly skipped"; \
      if [ "$ADD_REDOCLY" = "true" ] && [ "$ADD_NODEJS" = "false" ]; then \
        echo "Redocly requires Node.js"; \
      fi \
   ; fi

# Configure Git global settings (runs as $RUN_USER; writes to ~/.gitconfig)
RUN if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then \
      git config --global user.name "$GIT_NAME" && \
      git config --global user.email "$GIT_EMAIL" \
    else \
      git config --global --add safe.directory $WORKDIR \
    ; fi

# Install Oh My Zsh and configure Zsh for interactive work context.
# RUNZSH=no prevents the installer from launching a new shell (which blocks builds).
# CHSH=no skips the chsh call — we already set zsh as the shell above.
RUN if [ "$IMAGE_CONTEXT" = "work" ]; then \
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && echo 'autoload -Uz compinit; compinit' >> /home/$RUN_USER/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /home/$RUN_USER/.zshrc \
    && echo "export EDITOR=${DEFAULT_EDITOR}" >> /home/$RUN_USER/.zshrc \
    && echo 'alias jekyllserve="jekyll serve --host=0.0.0.0"' >> /home/$RUN_USER/.zshrc \
    && echo 'PROMPT="%n@$IMAGE_CONTEXT:%~%# "' >> /home/$RUN_USER/.zshrc \
    && echo 'HISTFILE=/commandhistory/.zsh_history' >> /home/$RUN_USER/.zshrc \
    && echo 'HISTSIZE=10000' >> /home/$RUN_USER/.zshrc \
    && echo 'SAVEHIST=10000' >> /home/$RUN_USER/.zshrc \
    && echo 'setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS' >> /home/$RUN_USER/.zshrc \
  ; fi

# Copy project dependency manifests so a post-build script can run bundle/npm/pip install.
# These are no-op placeholders by default; override with your own files.
COPY --chown=$HOST_UID:$HOST_GID $DOCKERFILE_DIR/Gemfile* $WORKDIR/
COPY --chown=$HOST_UID:$HOST_GID $DOCKERFILE_DIR/package.json $WORKDIR/
COPY --chown=$HOST_UID:$HOST_GID $DOCKERFILE_DIR/requirements.txt $WORKDIR/

# HOOK for custom post-build operations.
# dockerfile-post-build.sh is a placeholder by default (runs as a no-op).
# Replace it with real commands to pre-install gems, run bundle install, or
# perform any other final setup. Same "file must exist" requirement as the pre-hook.
COPY --chown=$HOST_UID:$HOST_GID $BUILD_SCRIPT_POST $WORKDIR/build-script-post.sh
RUN chmod +x $WORKDIR/build-script-post.sh \
    && $WORKDIR/build-script-post.sh $POST_BUILD_SCRIPT_ARGS

# Switch back to root to install the entrypoint. The entrypoint runs as root,
# performs UID/GID reconciliation if HOST_UID/HOST_GID are set, then drops
# privileges via gosu before executing the user's command.
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR $WORKDIR

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# bash is the universal fallback CMD for both work and live contexts: the live
# context never installs zsh, so CMD ["zsh"] would break it. In practice,
# compose.yml overrides this to `zsh` for the work context, and the devcontainer
# postCreateCommand does the same. Direct `docker run` on a work image will open
# bash; use `docker run ... zsh` or set `command: zsh` in compose.yml if needed.
CMD [ "bash" ]