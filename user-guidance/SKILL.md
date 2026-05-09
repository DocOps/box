---
name: user-guidance
description: Help users successfully install and engage the `dxbx` CLI and the Docker/VS
  Code Dev Container environment it manages.
tables-to-markdown: 'true'
---

# LLM Agent Guide
As an LLM agent assisting users of DocOps Box, your role is to help them successfully install and use the `dxbx` CLI and the Docker/VS Code Dev Container environment it manages.

Guide users to use the `dxbx` commands and configuration options as documented here—do not substitute Docker or other conventions unless something is not working. The ideal is to help users gain confidence with the provided system so they can be self-sufficient in their documentation and document-management projects.

<a id="_the_project"></a>
## The Project

This project includes an introductory guide and quick-start procedure for establishing and maintaining a broadly capable environment for **documentation management and document-processing** work.

DocOps Box uses **Docker** and **VS Code Dev Containers** to provide a consistent, reproducible environment for digital document management across different operating systems and team members.

The provided system also works for solo practitioners who want a stable, isolated environment for their docs projects without the hassle of managing dependencies on their host system. This project provides a guide and assets for meeting **_non_-developer tech or clerical workers** , typically on their **Windows** or maybe **MacOS** systems, not yet set up as “development environments” with tools like <strong class="buzz">Ruby</strong>, <strong class="buzz">Node.js</strong>, <strong class="buzz">Python</strong>, <strong class="buzz">Git</strong>, <strong class="buzz">Pandoc</strong>, <strong class="buzz">Vale</strong> and the world of capabilities that these tools open up.

<a id="_prerequisites"></a>
## Prerequisites

Several major software packages are required to use DocOps Box, including Docker Desktop, Visual Studio Code, and the `dxbx` CLI.

Use the relevant guide for the user’s operating system:

- [macOS](../host-prerequisites-macos/SKILL.md)
- [Windows](../host-prerequisites-windows/SKILL.md)

<a id="_installation"></a>
## Installation

Offer to take these steps one at a time, to explain as you go, and to verify the safety of each step before proceeding.

In any directory you maintain docs in…​

```
curl -fsSL https://raw.githubusercontent.com/DocOps/box/refs/heads/latest
scripts/dxbx-bootstrap.sh -o dxbx-bootstrap.sh
chmod +x dxbx-bootstrap.sh
sh ./dxbx-bootstrap.sh
dxbx init
rm dxbx-bootstrap.sh
dxbx ex docops info
```

<a id="_project_initialization"></a>
## Project Initialization

```
dxbx init
```

This downloads `docopsbox.yml` and `.env` into `.config/`, makes `.devcontainer/devcontainer.json`, prompts for a project slug, and updates `.gitignore` automatically.

**Check for new files**  
```
ls -a .config/ .devcontainer/
```

<a id="_configuration"></a>
## Configuration
<a id="environment-variables-env"></a>
### Environment Variables (.config/.env)

The `.config/.env` file is committed to your repository. It contains only safe, non-secret project-specific configuration.

| Variable | Default | Description |
| --- | --- | --- |
| `PROJECT_SLUG` | see below | Short identifier used to name the per-project gem volume. Set this to something unique across your projects. |
| `IMAGE_VARIANT` | `max` | `max` (full toolset, adds Node.js and Python) or `min` (core docs tools: Ruby, Pandoc, Vale, Git). Shell environment (Zsh vs Bash) is controlled by `IMAGE_CONTEXT`, not variant. |
| `IMAGE_CONTEXT` | `work` | `work` (interactive, OhMyZsh) or `live` (automation, Bash only). |
| `RUBY_VERSION` | (unset) | Selects a specific Ruby version. Omit (or leave unset) to use the default (3.3). |
| `IMAGE_REGISTRY` | `docopslab` | Docker Hub username or registry prefix for the image. |

The `PROJECT_SLUG` environment variable is used to create unique volume names for each project, so that dependencies installed in one project do not interfere with those in another. It defaults to the parent directory name, but you can set it to any short identifier you like.

> **NOTE:** `RUBY_VERSION` also controls which pre-built image tag is pulled from Docker Hub. Set it to select a non-default Ruby version without rebuilding anything.

<a id="secret-environment-variables-env-local"></a>
### Secret Environment Variables (.config/.env.local)

The `.config/.env.local` file is created during `dxbx init`.

Uncomment values as needed. This file is never committed to Git.

| Variable | Use |
| --- | --- |
| `HOST_UID` | Override the UID[<sup>🔖</sup>](#gloss-uid-gid) used for file ownership inside the container. Set to match `id -u` on the host if you see permission errors. |
| `HOST_GID` | Same as above for group ID (`id -g`). |
| `IMAGE_REGISTRY` | Override to a private registry or local mirror. |

<a id="project-slug-resolution"></a>
### Project Slug Resolution Order

The `dxbx` utility resolves the `PROJECT_SLUG` in this order:

1. `PROJECT_SLUG` from `.config/.env` or `.config/.env.local`, if present, or else
2. `:this_proj_slug:` AsciiDoc attribute in `README.adoc`, if present, or else
3. current directory name (spaces and underscores to hyphens, all lowercased)

<a id="_image_selection"></a>
### Image Selection
<a id="_per_invocation_overrides"></a>
#### Per-invocation Overrides

In most cases, you will likely only need a single image for starting containers on your local machine. Thus, the main invocation commands will (`dxbx up`, `dxbx ex`) execute a container based on the default image.

In case you wish to use an alternate image/container, `dxbx up`, `dxbx ex`, and `dxbx pull` subcommands all accept an optional image specifier as their first argument. This selects the image for that invocation without editing any files.

| Form | Selects |
| --- | --- |
| `min` or `max` | Variant only; context from config |
| `work` or `live` | Context only; variant from config |
| `max:live`, `max live` | Both variant and context |
| `box-min`, `box-max` | Same as `min`/`max` (the `box-` prefix is accepted) |

**Run a one-off command in the `min:live` image (no running container needed)**  
```
dxbx ex min:live bundle exec rake test
```

#What just happened?

The above command runs `bundle exec rake test` in a new container based on the bare-bones `box-min:live` image.

**Start an interactive session explicitly in the `max:work` image**  
```
dxbx up max:work
```

#What just happened?

The above command starts a new container based on the `box-max:work` image and gives you an interactive shell inside it.

In a default environment, this is the same as just running `dxbx up` with no image specifier.

**Test a script on the Ruby 3.4 image**  
```
dxbx ex work 3.4 ruby ./scripts/test-script.rb
```

#What just happened?

The above command runs `ruby ./scripts/test-script.rb` in a new container based on the `box-work:3.4` image, which has Ruby 3.4 installed.

Shell-level environment variables (`IMAGE_CONTEXT`, `IMAGE_VARIANT`) also perform this function. The image tag format is: `<registry>/box-<variant>:<context>` or, for a specific Ruby version, `<registry>/box-<variant>:<context>-<ruby>`.

For example: `docopslab/box-max:work` or `docopslab/box-max:work-3.4`

| Setting | Values | Notes |
| --- | --- | --- |
| `IMAGE_VARIANT` | `max`, `min` | `min` includes Ruby, Bundler, Git, Pandoc, and Vale.`max` adds Node.js, Python, and auxiliary tools. |
| `IMAGE_CONTEXT` | `work`, `live` | `work` configures Zsh with Oh My Zsh for interactive daily use;`live` uses Bash only, with no interactive enhancements; suited for CI/CD automation. |
| `RUBY_VERSION` | `3.3`, `3.4` | Selects a specific published Ruby version; omit to use the default (3.3). Setting this appends the version to the context tag: `work` becomes `work-3.4`. |

<a id="_examples"></a>
#### Examples

In most cases, you will likely only need a single image for starting containers on your local machine. Thus, the main invocation commands will (`dxbx up`, `dxbx ex`) execute a container based on the default image.

In case you wish to use an alternate image/container, `dxbx up`, `dxbx ex`, and `dxbx pull` subcommands all accept an optional image specifier as their first argument. This selects the image for that invocation without editing any files.

| Form | Selects |
| --- | --- |
| `min` or `max` | Variant only; context from config |
| `work` or `live` | Context only; variant from config |
| `max:live`, `max live` | Both variant and context |
| `box-min`, `box-max` | Same as `min`/`max` (the `box-` prefix is accepted) |

**Run a one-off command in the `min:live` image (no running container needed)**  
```
dxbx ex min:live bundle exec rake test
```

#What just happened?

The above command runs `bundle exec rake test` in a new container based on the bare-bones `box-min:live` image.

**Start an interactive session explicitly in the `max:work` image**  
```
dxbx up max:work
```

#What just happened?

The above command starts a new container based on the `box-max:work` image and gives you an interactive shell inside it.

In a default environment, this is the same as just running `dxbx up` with no image specifier.

**Test a script on the Ruby 3.4 image**  
```
dxbx ex work 3.4 ruby ./scripts/test-script.rb
```

#What just happened?

The above command runs `ruby ./scripts/test-script.rb` in a new container based on the `box-work:3.4` image, which has Ruby 3.4 installed.

Shell-level environment variables (`IMAGE_CONTEXT`, `IMAGE_VARIANT`) also perform this function. The image tag format is: `<registry>/box-<variant>:<context>` or, for a specific Ruby version, `<registry>/box-<variant>:<context>-<ruby>`.

For example: `docopslab/box-max:work` or `docopslab/box-max:work-3.4`

| Setting | Values | Notes |
| --- | --- | --- |
| `IMAGE_VARIANT` | `max`, `min` | `min` includes Ruby, Bundler, Git, Pandoc, and Vale.`max` adds Node.js, Python, and auxiliary tools. |
| `IMAGE_CONTEXT` | `work`, `live` | `work` configures Zsh with Oh My Zsh for interactive daily use;`live` uses Bash only, with no interactive enhancements; suited for CI/CD automation. |
| `RUBY_VERSION` | `3.3`, `3.4` | Selects a specific published Ruby version; omit to use the default (3.3). Setting this appends the version to the context tag: `work` becomes `work-3.4`. |

<a id="_image_variants_and_contexts"></a>
#### Image Variants and Contexts

In most cases, you will likely only need a single image for starting containers on your local machine. Thus, the main invocation commands will (`dxbx up`, `dxbx ex`) execute a container based on the default image.

In case you wish to use an alternate image/container, `dxbx up`, `dxbx ex`, and `dxbx pull` subcommands all accept an optional image specifier as their first argument. This selects the image for that invocation without editing any files.

| Form | Selects |
| --- | --- |
| `min` or `max` | Variant only; context from config |
| `work` or `live` | Context only; variant from config |
| `max:live`, `max live` | Both variant and context |
| `box-min`, `box-max` | Same as `min`/`max` (the `box-` prefix is accepted) |

**Run a one-off command in the `min:live` image (no running container needed)**  
```
dxbx ex min:live bundle exec rake test
```

#What just happened?

The above command runs `bundle exec rake test` in a new container based on the bare-bones `box-min:live` image.

**Start an interactive session explicitly in the `max:work` image**  
```
dxbx up max:work
```

#What just happened?

The above command starts a new container based on the `box-max:work` image and gives you an interactive shell inside it.

In a default environment, this is the same as just running `dxbx up` with no image specifier.

**Test a script on the Ruby 3.4 image**  
```
dxbx ex work 3.4 ruby ./scripts/test-script.rb
```

#What just happened?

The above command runs `ruby ./scripts/test-script.rb` in a new container based on the `box-work:3.4` image, which has Ruby 3.4 installed.

Shell-level environment variables (`IMAGE_CONTEXT`, `IMAGE_VARIANT`) also perform this function. The image tag format is: `<registry>/box-<variant>:<context>` or, for a specific Ruby version, `<registry>/box-<variant>:<context>-<ruby>`.

For example: `docopslab/box-max:work` or `docopslab/box-max:work-3.4`

| Setting | Values | Notes |
| --- | --- | --- |
| `IMAGE_VARIANT` | `max`, `min` | `min` includes Ruby, Bundler, Git, Pandoc, and Vale.`max` adds Node.js, Python, and auxiliary tools. |
| `IMAGE_CONTEXT` | `work`, `live` | `work` configures Zsh with Oh My Zsh for interactive daily use;`live` uses Bash only, with no interactive enhancements; suited for CI/CD automation. |
| `RUBY_VERSION` | `3.3`, `3.4` | Selects a specific published Ruby version; omit to use the default (3.3). Setting this appends the version to the context tag: `work` becomes `work-3.4`. |

<a id="_commands_reference"></a>
## Commands Reference
<a id="_volume_management"></a>
### Volume Management

If your volumes ever become problematic or stale for any reason, it is safe to remove the disposable ones, which will be recreated on demand.

| Command | Effect |
| --- | --- |
| `dxbx stat` | Show container state and volume sizes. |
| `dxbx wipe --vols` | Remove the container and all per-project dependency volumes (Ruby gems, Node packages, Python venv); preserve shell history. |
| `dxbx wipe --hist` | Remove dependency volumes **and** shell history (requires double confirmation). |
| `dxbx back` | Copy shell history to `~/.local/share/docopslab/dxbx/backups/` before destructive operations. |
| `dxbx back --restore` | Restore shell history from a backup (append or replace). |

<a id="_volumes_and_persistence"></a>
## Volumes and Persistence
<a id="_named_volumes"></a>
### Named Volumes

<dl>
<dt>`docops-shell-history`</dt>
<dd>
Mounts at `/commandhistory`. Shared across all projects. Contains your Zsh history. Do not delete without backing up first.
</dd>
<dt>`docops-<slug>-bundle`</dt>
<dd>
Per-project Ruby gem cache. Mounts at `/usr/local/bundle`. Safe to recreate at any time; `bundle install` repopulates it.
</dd>
<dt>`docops-<slug>-node`</dt>
<dd>
Per-project Node.js packages. Mounts at `/workspace/node_modules`. Safe to recreate; `npm install` repopulates it. An empty `node_modules/` directory will appear in your project root. This is Docker’s mount point; the actual contents are inside the named volume and invisible to the host.
</dd>
<dt>`docops-<slug>-python`</dt>
<dd>
Per-project Python virtual environment. Mounts at `/opt/venv`. Safe to recreate; `pip install -r requirements.txt` repopulates it. Run `pip install` normally inside the container; no flags needed.
</dd>
</dl>

> **NOTE:** If you alternate between Ruby versions, you will need to install dependencies for each version. The Bundler volume will remain the same, but the gems will be installed in separate subdirectories per Ruby version.

<a id="_troubleshooting"></a>
## Troubleshooting
<a id="_diagnostics"></a>
### Diagnostics

Run this first when something is not working.

```
dxbx stat
```

This covers the most common problems:

- Docker Engine version and availability
- Docker Compose version
- Image presence and tag verification
- Volume existence and size inspection
- WSL2 environment detection
- Actionable error messages for common failure conditions<dl>
<dt>1: `Error: No such service: docops`</dt>
<dd>
`dxbx` is not running from the directory containing `.config/docopsbox.yml`.

  1. Change to the project root and try again, or
  2. Use `dxbx init` to set up the configuration files.
</dd>
<dt>2: Permission denied writing files on Linux</dt>
<dd>
Files the container writes are owned by the container user, which may differ from your host user. Set `HOST_UID` and `HOST_GID` in `.config/.env.local` to match your host user:

```
# Find your host UID and GID
id -u # prints your UID
id -g # prints your GID
```

**config/.env.local**  
```
HOST_UID=1001 # replace with output of: id -u
HOST_GID=1001 # replace with output of: id -g
```

Then re-run `dxbx up`.
</dd>
<dt>3: `bundle install` fails inside the container</dt>
<dd>
1. Be sure `Gemfile` is in the mounted project root.

  2. Be sure your present working directory is `/workspace` inside the container.

  3. The bundle volume may have stale or corrupted gem data. Clear and rebuild it:
</dd>
<dt>4: Gems fail to load after updating Ruby version</dt>
<dd>
Native gem extensions (compiled C code inside gems like `nokogiri` or `ffi`) are compiled for a specific Ruby version.

=== Common Issues

Run this first when something is not working.

```
dxbx stat
```

This covers the most common problems:

  - Docker Engine version and availability
  - Docker Compose version
  - Image presence and tag verification
  - Volume existence and size inspection
  - WSL2 environment detection
  - Actionable error messages for common failure conditions<dl>
<dt>5: `Error: No such service: docops`</dt>
</dl>

`dxbx` is not running from the directory containing `.config/docopsbox.yml`.
</dd>
</dl>

1. Change to the project root and try again, or
2. Use `dxbx init` to set up the configuration files.

<dl>
<dt>6: Permission denied writing files on Linux</dt>
</dl>

Files the container writes are owned by the container user, which may differ from your host user. Set `HOST_UID` and `HOST_GID` in `.config/.env.local` to match your host user:

```
# Find your host UID and GID
id -u # prints your UID
id -g # prints your GID
```

**config/.env.local**  
```
HOST_UID=1001 # replace with output of: id -u
HOST_GID=1001 # replace with output of: id -g
```

Then re-run `dxbx up`.

<dl>
<dt>7: `bundle install` fails inside the container</dt>
</dl>

1. Be sure `Gemfile` is in the mounted project root.

2. Be sure your present working directory is `/workspace` inside the container.

3. The bundle volume may have stale or corrupted gem data. Clear and rebuild it:

<dl>
<dt>8: Gems fail to load after updating Ruby version</dt>
</dl>

Native gem extensions (compiled C code inside gems like `nokogiri` or `ffi`) are compiled for a specific Ruby version.

