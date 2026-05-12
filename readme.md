# DocOps Box
Get up and running with **docs-as-code**!

DocOps Box is a documentation multi-tool for your Mac or PC.

This project includes an introductory guide and quick-start procedure for establishing and maintaining a broadly capable environment for **documentation management and document-processing** work.

DocOps Box uses **Docker** and **VS Code Dev Containers** to provide a consistent, reproducible environment for digital document management across different operating systems and team members.

The provided system also works for solo practitioners who want a stable, isolated environment for their docs projects without the hassle of managing dependencies on their host system.

> **TIP:** LLMs or people engaging LLMs/agents to help them use DocOps Box should reference [this JSON outline of the core agent guidance skill](https://raw.githubusercontent.com/DocOps/box/refs/heads/agent-docs/user-guidance/skill-skim.json). There is also a [Markdown version of this README](https://raw.githubusercontent.com/DocOps/box/refs/heads/agent-docs/readme.md) (with a [JSON skim outline](https://raw.githubusercontent.com/DocOps/box/refs/heads/agent-docs/readme-skim.json) for token savings).

Even if you don’t use the images or tools provided, this guide should still be helpful for anyone orienting to the world of docs-as-code tools and workflows. It includes a section for [“host installation”](#ruby-for-real) of all the tools supported by the container approach, so you can choose your own adventure if you prefer to set up your workstation without Docker.

Table of Contents

1. [Introduction](#intro)
  1. [Tooling Overview](#tooling-overview)
  2. [When to Use DocOps Box](#when-to-use)
  3. [Host Install vs DocOps Box](#host-vs-docopsbox)
2. [Prerequisites](#prerequisites)
  1. [Terminal App (All OSes; Advised)](#prereq-terminal)
  2. [VS Code (All OSes; Advised)](#prereq-vscode)
  3. [Bash 4+ (MacOS Only)](#prereq-bash4)
  4. [WSL2 (Windows Only)](#prereq-wsl2)
  5. [Curl (All Hosts; Required)](#prereq-curl)
  6. [Docker (All OSes)](#prereq-docker)
3. [DocOps in a Box: Quick-start Guide](#quickstart)
  1. [Quickest Start](#quickest-start)
  2. [Step 1: Install dxbx (once, system-wide)](#step-install-dxbx)
  3. [Step 2: Initialize your project (optional)](#step-initialize-your-project)
  4. [Step 3: Test dxbx with default image](#step-test-dxbx)
  5. [Step 4: Start working](#step-container-workflow)
4. [Using Your New Environment](#usage)
  1. [Understanding Your Shells](#shell-cli-orientation)
  2. [Volume Lifecycle](#volume-lifecycle)
  3. [Per-invocation Image Overrides](#image-overrides)
  4. [Adding Runtime Dependencies](#adding-dependencies)
  5. [Open a server port](#open-server-port)
5. [Configuration Reference](#configuration)
  1. [Environment Variables (.config/.env)](#environment-variables-env)
  2. [Secret Environment Variables (.config/.env.local)](#secret-environment-variables-env-local)
  3. [Project Slug Resolution Order](#project-slug-resolution)
  4. [Image Variants and Contexts](#image-variants-contexts)
  5. [Docker Compose Configuration (docopsbox.yml)](#compose-config)
  6. [VS Code Dev Container Configuration (.devcontainer/devcontainer.json)](#devcontainer-config)
6. [Troubleshooting](#troubleshooting)
  1. [Start with Diagnostics](#start-with-diagnostics)
  2. [Common Issues](#common-issues)
7. [Extending DocOps Box](#extending)
  1. [Custom Image Builds](#custom-image-builds)
8. [Appendices](#appendices)
  1. [Appendix A: Who is This Software For?](#who-for)
  2. [Appendix B: Glossary](#glossary)
  3. [Appendix C: Auxiliary Tools](#auxiliary-tools)
  4. [Appendix D: Installing Everything to Host](#ruby-for-real)
  5. [Appendix E: Background and Context](#background-context)
  6. [Appendix F: Development and Contribution](#development)

<a id="intro"></a>
## Introduction

This project provides a guide and assets for meeting **_non_-developer tech or clerical workers** , typically on their **Windows** or maybe **MacOS** systems, not yet set up as “development environments” with tools like <strong class="buzz">Ruby</strong>, <strong class="buzz">Node.js</strong>, <strong class="buzz">Python</strong>, <strong class="buzz">Git</strong>, <strong class="buzz">Pandoc</strong>, <strong class="buzz">Vale</strong> and the world of capabilities that these tools open up.

> **NOTE:** This entire project is geared toward **Windows, Mac, _and_ Linux** users, but it assumes virtually zero Linux/Unix knowledge or preference. You will be using a command line (terminal), and it needs to be (1) Mac-based or (2) Linux-based (including via WSL2 on Windows).

This project is intended to meet users where I have found these “tech-savvy non-programmers” among my clients the past several years, such as <strong class="buzz">technical writers</strong>, <strong class="buzz">project managers</strong>, and professional <strong class="buzz">document wranglers</strong> like <strong class="buzz">paralegals</strong>, non-software <strong class="buzz">engineers</strong>, <strong class="buzz">researchers</strong>, and <strong class="buzz">educators</strong>.

This toolkit is intended to provide a proper swath of technologies in the form of a **specially designed Docker image** [<sup>🔖</sup>](#gloss-image) you can run as a container[<sup>🔖</sup>](#gloss-container) on your system, whatever that system may be.

DocOps Box is specifically geared toward the [AYL DocStack](https://docopslab.org/projects/ayl-docstack/): applications using **AsciiDoc** , **YAML** , and **Liquid** to build documents and documentation. However, the `max` images can handle a huge swath of the most common tools and formats used in the docs-as-code world, such as **JavaScript** , **Markdown** , **reStructuredText** , **JSON** , **XML** , and more.

> **NOTE:** DocOps Box is tested on **Docusaurus** , **Antora** , **Astro** , **Jekyll** , **MkDocs** , **Sphinx** , and **11ty**. The `max` images are suitable for projects running any of these platforms as well as all the pre-installed tools found in [Tooling Overview](#tooling-overview).

The main intent is to provide the basics for these fairly technical/non-expert users to operate with the power of advanced “docs-as-code” techniques that only programmers, hackers, and IT professionals have typically bothered messing with until recently. See [Who is This Software For?](#who-for) for more on the intended user base and **use cases** for this project.

If you know you want to get started with DocOps Box, skip to [Prerequisites](#prerequisites) and perform any necessary installations there.

The next few sections are for users who want to understand the rationale and context for this project before diving in.

<a id="tooling-overview"></a>
### Tooling Overview

The only real requirement for a “Dockerized” (“containerized”) approach to establishing a robust DocOps environment, as provided in this project, is that you have Docker working on top of a Unix-like shell[<sup>🔖</sup>](#gloss-shell).

It makes the most sense for users who need a consistent mix of tools across multiple projects; setting up a separate Docker image per tool is at least as complicated as a native install.

> **NOTE:**  **Windows** users will need to set up a WSL2 kernel and a Linux distribution if they have not already done so. This much is true of any Windows-based approach advised by this project.

Technologies included in the DocOps Box Docker images are:

<dl>
<dt>Zsh</dt>
<dd>
The powerful and elegant terminal shell environment that is more user-friendly than Bash, already configured with [OhMyZsh](https://ohmyz.sh).`work` images only; `live` images use Bash
</dd>
<dt>[Git](https://git-scm.com)</dt>
<dd>
The most popular version control system, which is used to track changes to your codebase and to share it with others
</dd>
<dt>Ruby</dt>
<dd>
A runtime environment[<sup>🔖</sup>](#gloss-runtime) for executing Ruby command-line utilities and managing Ruby dependencies
</dd>
<dt>Node.js</dt>
<dd>
A runtime environment for numerous auxiliary tools that have no Ruby equivalent; included in `max` images only
</dd>
<dt>Python</dt>
<dd>
A runtime environment for the inevitable Python utilities; included in `max` images only
</dd>
<dt>[Pandoc](https://pandoc.org)</dt>
<dd>
An extraordinary document migration utility that can convert between a huge range of formats
</dd>
<dt>[Vale](https://vale.sh)</dt>
<dd>
A document validation utility (linter) that can check markup-formatted writing for consistent style and preferred grammar
</dd>
<dt>OpenAPI tools</dt>
<dd>
Three excellent OpenAPI Specification[<sup>🔖</sup>](#gloss-oas) utilities, for validating/linting OAS documents and generating API reference documentation from them ([Redocly CLI](https://redocly.com/docs/cli), [Vacuum](https://quobix.com/vacuum/), and [Speakeasy CLI](https://www.speakeasy.com/docs/speakeasy-reference/cli))
</dd>
<dt>text editors</dt>
<dd>
The images provide the [GNU nano](https://www.nano-editor.org) (default) and [Vim](https://www.vim.org), TUI[<sup>🔖</sup>](#gloss-tui) utilities for quick edits in the interactive shell.
</dd>
<dt>LibreOffice</dt>
<dd>
Powerful CLI utilities behind the popular office suite; included automatically in `max` images
</dd>
<dt>Ruby tools</dt>
<dd>
Out of the box (so to speak): [Asciidoctor](https://asciidoctor.org) (`.adoc` → `.html`/`.pdf`/`.epub`), [Kramdown-AsciiDoc](https://github.com/asciidoctor/kramdown-asciidoc) (`.md` → `.adoc`), [Nokogiri](https://nokogiri.org) (HTML/XML parsing), and other handy Ruby gems. Add your own per project using `Gemfile`; see [Adding Runtime Dependencies](#adding-dependencies).
</dd>
</dl>

See [the project’s `Dockerfile`](https://github.com/DocOps/box/tree/latest/Dockerfile) for the full list of installed packages and utilities. Many are secondarily documented below in [Auxiliary Tools](#auxiliary-tools) as well as [Installing Everything to Host](#ruby-for-real).

This environment is suitable for users to execute <strong class="term">scripts</strong> and <strong class="term">runtime applications</strong> like the ones I provide for and use with my clients. It’s what you need to apply my or anyone else’s Ruby-based documentation <strong class="term">toolchain</strong> or <strong class="term">tech stack</strong> to your specific purposes.

This project should also suit if your toolchain is <strong class="buzz">Javascript</strong>-based (<strong class="buzz">Docusaurus</strong>, <strong class="buzz">Antora</strong>, <strong class="buzz">Next.js</strong>, <strong class="buzz">SvelteKit</strong>, <strong class="buzz buzz-eleventy">11ty</strong>, <strong class="buzz">Astro</strong>, etc) or **Python** -based (<strong class="buzz">Sphinx/ReadTheDocs</strong>, <strong class="buzz">MkDocs</strong>). However, if your toolchain excludes Ruby altogether, this Ruby-centric project might not be the most efficient route to a stable coding environment.

<a id="when-to-use"></a>
### When to Use DocOps Box

This project is not intended to be a “one size fits all” solution for every docs-as-code project; it is optimized for relatively complex situations (multiple projects, multiple/complex toolchains, etc).

Use this table to decide if DocOps Box is right for your situation.

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 50%;">
<col style="width: 50%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Scenario</th>
<th class="halign-left valign-top">Recommendation</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top">You occasionally use one or two DocOps Lab tools</td>
<td class="halign-left valign-top">Use each tool’s own Docker image directly</td>
</tr>
<tr>
<td class="halign-left valign-top">You regularly use multiple DocOps Lab tools</td>
<td class="halign-left valign-top">Use DocOps Box (<code>min</code> or <code>max</code> image)</td>
</tr>
<tr>
<td class="halign-left valign-top">Your toolchain uses Ruby and Node/Python tools</td>
<td class="halign-left valign-top">Use a DocOps Box <code>max</code> image</td>
</tr>
<tr>
<td class="halign-left valign-top">Your toolchain uses runtimes other than Ruby, Node, or Python</td>
<td class="halign-left valign-top">DocOps Box will be partially helpful or unsuitable; advanced users might consider <a href="#extending">extending the image</a>
</td>
</tr>
<tr>
<td class="halign-left valign-top">You are setting up a team documentation environment</td>
<td class="halign-left valign-top">Use DocOps Box with a shared <code>.env</code> file in Git</td>
</tr>
<tr>
<td class="halign-left valign-top">You need a <span class="term">CI/CD</span><a href="#gloss-ci-cd"><sup>🔖</sup></a> pipeline for docs automation</td>
<td class="halign-left valign-top">Use DocOps Box <code>live</code> image</td>
</tr>
</tbody>
</table>

<a id="host-vs-docopsbox"></a>
### Host Install vs DocOps Box

DocOps Box, as a project, is not about pushing you into using _any_ specific software, including our Docker images or our `dxbx` script.

Full “native” or **host** installation instructions for _all_ core DocOps Box-supported components are included in an appendix: [Installing Everything to Host](#ruby-for-real).

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Criterion</th>
<th class="halign-left valign-top">Host Install</th>
<th class="halign-left valign-top">DocOps Box</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top">Setup time (first use)</td>
<td class="halign-left valign-top">45-90 min</td>
<td class="halign-left valign-top">~5 min</td>
</tr>
<tr>
<td class="halign-left valign-top">Reproducibility across machines</td>
<td class="halign-left valign-top">High effort</td>
<td class="halign-left valign-top">Automatic via config files</td>
</tr>
<tr>
<td class="halign-left valign-top">Team-wide standardization</td>
<td class="halign-left valign-top">Requires active coordination, docs</td>
<td class="halign-left valign-top">Git-committed <code>.env</code> + <code>docopsbox.yml</code>
</td>
</tr>
<tr>
<td class="halign-left valign-top">Works on Windows</td>
<td class="halign-left valign-top">WSL2 + manual setup</td>
<td class="halign-left valign-top">WSL2 + Docker</td>
</tr>
<tr>
<td class="halign-left valign-top">IDE integration <span class="nowrap">(VS Code)</span>
</td>
<td class="halign-left valign-top">Full native</td>
<td class="halign-left valign-top">Full via Dev Containers extension</td>
</tr>
<tr>
<td class="halign-left valign-top">Per-project dependencies isolation</td>
<td class="halign-left valign-top">As configured per runtime/project</td>
<td class="halign-left valign-top">Named volumes <a href="#gloss-volume"><sup>🔖</sup></a> handled by <code>dxbx</code>
</td>
</tr>
<tr>
<td class="halign-left valign-top">Suitable for CI/CD</td>
<td class="halign-left valign-top">Requires environment setup steps</td>
<td class="halign-left valign-top">Available via <code>live</code> image</td>
</tr>
</tbody>
</table>

<a id="prerequisites"></a>
## Prerequisites

All of the software required to run DocOps Box is **free** , **open source** , and strongly **recommended** for any modern code-like documentation workflow. You cannot go wrong having VS Code and Docker on your workstation, even if you do not end up using DocOps Box over the long term.

> **TIP:** This document is intended to guide you to competency in the world of docs-as-code, not merely using `dxbx` and its Docker containers. Everything advised has a graceful fallback to [direct installation on your host system](#ruby-for-real).

Work through the following steps in order.

<dl>
<dt>Prerequisites:</dt>
<dd>
- [Terminal app](#prereq-terminal)
- [VS Code](#prereq-vscode)
- [Bash 4+ (MacOS only)](#prereq-bash4)
- [WSL2 (Windows only)](#prereq-wsl2)
- [Curl](#prereq-curl)
- [Docker](#prereq-docker)
</dd>
</dl>

This section is somewhat long but should move along quickly. All of these apps are critical, some are likely already available on your system, and this guide covers installing them on any major platform.

> **WARNING:** DocOps Box images require free space on your local disk. The `max:work` images are around 2.3 GB, and the `min:live` images are around 700 MB.
<a id="prereq-terminal"></a>
### Terminal App (All OSes; Advised)

There is no avoiding the command line in the docs-as-code world. If you already have a terminal you like, use it and skip ahead.

> **TIP:** It is **strongly advised** that you choose a terminal app _other than the one in VS Code_, simply for differentiation of duties, at least when getting started. Use VS Code’s terminal inside the containerized environment; use an external terminal for `dxbx` commands and other host-level work.

If you are unaware of or unhappy with your terminal app, here are my recommendations per operating system.

<a id="warp-wave-terminal"></a>
#### Warp and Wave

By far my two favorite terminal apps are Warp and Wave. Both are free, open-source programs with optional AI integration, at a cost.

> **WARNING:** Both Wave and Warp install with telemetry be enabled by default, and it is required for free AI use. Paid users can opt out of telemetry, as can free users not wishing to partake of the AI features.

Warp has a fully AI-integrated terminal that can be a little bit overwhelming but provides excellent interactivity between terminal and GUI[<sup>🔖</sup>](#gloss-gui).

Wave’s AI aspect is chat-only for now, so you have to copy and paste commands and output back and forth, though the chat can automatically read local files.

Both are excellent terminal emulators _aside from or despite_ the optional AI tie-in.

- [Download Warp](https://www.warp.dev/terminal) (downloads for all platforms in page footer)
- [Download Wave](https://www.waveterm.dev/download)

<a id="os-terminals"></a>
#### OS-specific terminal apps

If you prefer to install from an app store or package manager, here are some good options on all three platforms.

- **Windows users** can use the built-in Windows Terminal, which supports multiple shells including PowerShell and WSL2. If it’s not installed, get it from the Microsoft Store: [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701).

- **MacOS users** can use the built-in Terminal app, but most users prefer [iTerm2](https://iterm2.com/downloads.html), which is also available as a Homebrew package:

- **Linux users** are unlikely to find better options than Wave or Warp. If you are a Linux user who does not already have a preference, try one of those or your distro’s default terminal app.

<a id="prereq-vscode"></a>
### VS Code (All OSes; Advised)

The recommended daily workflow uses VS Code with the Dev Containers extension as your main interface.

> **NOTE:** VS Code is not truly a _requirement_ for the DocOps Box workflow, but it is strongly recommended for novice users without a strong reason to choose another workflow. Your favorite IDE/text editor is just as valid, in combination with its own terminal or another that you prefer. If you have no strong preference, give VS Code a try.

1. Install [Visual Studio Code](https://code.visualstudio.com).

2. Install the **Dev Containers** extension from the VS Code Marketplace:

Whenever your workspace path in VS Code is configured with a `.devcontainer/devcontainer.json`, VS Code will prompt you to “Reopen in Container”, which gives you the full DocOps Box environment with all the tools installed and configured.

Or, you can always use `dxbx vsc` from the project root directory in your terminal to open a VS Code window with the containerized environment.

<dl>
<dt>Recommended plugins:</dt>
<dd>
- **(Windows/WSL users)** [Remote Development Extension Pack from Microsoft](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) (includes Dev Containers)
- **(MacOS/Linux users)** [Dev Containers from Microsoft](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
- [Docker from Microsoft](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
</dd>
<dt>Recommended for AsciiDoc/YAML/Liquid work:</dt>
<dd>
- [AsciiDoc from Asciidoctor](https://marketplace.visualstudio.com/items?itemName=asciidoctor.asciidoctor-vscode)
- [Liquid from Shopify](https://marketplace.visualstudio.com/items?itemName=Shopify.theme-check-vscode)
- [YAML from Red Hat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
- [Learn YAML from Microsoft](https://marketplace.visualstudio.com/items?itemName=docsmsft.docs-yaml)
</dd>
<dt>Recommended configuration changes under <kbd class="menuseq"><kbd class="menu"><samp>File</samp></kbd> <span class="caret">›</span> <kbd class="menu"><samp>Preferences</samp></kbd> <span class="caret">›</span> <kbd class="menu"><samp>Settings</samp></kbd></kbd>:</dt>
<dd>
- Set **Wrapping Indent** to `indent`
- Set **Editor: Format On Save** to `true`
</dd>
<dt>Privacy/security settings:</dt>
<dd>
- Search `telemetry` and disable where you prefer:
  - Set **Telemetry: Feedback** to `disabled`
  - Set **Telemetry: Telemetry Level** to `off`
- Set **Extensions: Auto Update** to `true`
</dd>
</dl>

> **TIP:** - Native (non-Windows) Linux users can skip to [Docker (All OSes)](#prereq-docker).
> - Windows users can skip to [WSL2 (Windows Only)](#prereq-wsl2).

<a id="prereq-bash4"></a>
### Bash 4+ (MacOS Only)

The [quick-start](#quickstart) procedure will ensure you have Bash 4 or higher on your host. For legal reasons, MacOS comes with Bash 3, but it is highly advised and **100% harmless** to add Bash 4+ to your system.

> **NOTE:** Adding Bash 4 does not replace Z Shell as your default system/interactive shell.

The bootstrap script will offer to install Bash 4+ via Homebrew (as well as Homebrew itself) if not already present.

Like all prerequisites, Bash 4 is an essential tool for working with developer tools and workflows.

> **TIP:** Mac users can skip to [Docker (All OSes)](#prereq-docker).

<a id="prereq-wsl2"></a>
### WSL2 (Windows Only)
> **TIP:** _If you are on MacOS or Linux_, [skip this step](#prereq-docker).

The most reliable way to use a Unix-like shell on Windows is to install via the oddly named **Windows Subsystem for Linux** or **WSL2**. This is the biggest step for Windows users, but it is also straightforward and well-documented by Microsoft.

1. Ensure your Windows version supports WSL2.

2. Open **Windows Terminal** as an administrator.

3. Run the WSL2 installer:

That last command should perform the entire setup procedure.

> **NOTE:** If this procedure does not work, follow the [official Microsoft installation guide](https://learn.microsoft.com/en-us/windows/wsl/install).

To enter a WSL2 session in the future, open your [terminal client](#prereq-terminal) and enter `wsl`.

> **IMPORTANT:** All project folders intended for use with DocOps Box should live inside the WSL2 filesystem (`~/…​`), not on the Windows mount (`/mnt/c/…​`). File I/O through the Windows mount is significantly slower and causes subtle permission issues.

<a id="prereq-curl"></a>
### Curl (All Hosts; Required)

Curl is a command-line utility for making HTTP requests, which is used to download the `dxbx` script. It is a common and highly recommended tool, but it may not come preinstalled in all Linux distributions, including Ubuntu via WSL2 on Windows.

**Test for `curl`**  
```
curl --version
```

> **TIP:** If `curl` is available, proceed to [Docker (All OSes)](#prereq-docker).

If `curl` not present, install it with your package manager.

**Install `curl` for Debian/Ubuntu**  
```
sudo apt-get update
sudo apt-get install curl
```

<a id="prereq-docker"></a>
### Docker (All OSes)

Docker is a platform that allows you to run a _containerized Linux environment_ on your system. Containers are much lighter and more customizable than full virtual machines. They are specifically designed for creating consistent environments for development and automation.

See [Threading the needle with Docker](#threading-needle), [Architecture Decision Rationale](#adr), and _most usefully_ the [Docker glossary section](#glossary-docker) for more context. This section covers the nuts and bolts of installation.

<a id="docker-wsl2"></a>
#### Docker on Windows (WSL2)

Microsoft maintains [documentation for setting up Docker with WSL2](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers#install-docker-desktop).

> **TIP:** Follow that guide, then move on to [DocOps in a Box: Quick-start Guide](#quickstart).

<a id="docker-macos"></a>
#### Docker on MacOS

The preferred method is the [Docker Desktop installer](https://docs.docker.com/desktop/install/mac-install/).

Alternatively, use [Homebrew](https://brew.sh). Follow [these instructions](https://www.delftstack.com/howto/docker/brew-docker/) to install Homebrew if needed as well as full instructions for installing and starting Docker.

<a id="docker-linux"></a>
#### Docker on Linux (non-WSL)
> **WARNING:** Linux users running under WSL2 should install Docker according to [Docker on Windows (WSL2)](#docker-wsl2). Do not install Docker directly onto the WSL2 host instance.

Install Docker Engine using Docker’s official convenience script:

```
curl -fsSL https://get.docker.com | sudo sh
```

The script prints progress and some informational notes about alternative configurations, which you can ignore. When it finishes, enable Docker to start automatically at boot and start it now:

```
sudo systemctl enable --now docker
```

Then grant your user permission to run Docker without `sudo`:

```
sudo usermod -aG docker $USER
```

> **NOTE:** For distro-specific or manual installation, see [Docker’s official install docs](https://docs.docker.com/engine/install).
**Verify Docker is working**  
```
docker --version && docker compose version
```

Both commands should print a version number with no errors before you continue.

<a id="quickstart"></a>
## DocOps in a Box: Quick-start Guide

_If you have all the [**prerequisites**](#prerequisites) in place_, the recommended quick-start procedure is to use `dxbx` and a DocOps Box work image to get a containerized environment up and running in just a few minutes.

<a id="quickest-start"></a>
### Quickest Start

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

For a more detailed, explanatory walkthrough of the same procedure, see [step through the next sections](#step-install-dxbx).

If this _quickest start_ set up worked for you, skip to [Step 4: Start working](#step-container-workflow).

<a id="step-install-dxbx"></a>
### Step 1: Install dxbx (once, system-wide)

If you have not installed `dxbx` yet, copy, paste, and enter this once in your host shell:

```
curl -fsSL https://raw.githubusercontent.com/DocOps/box/refs/heads/latest
scripts/dxbx-bootstrap.sh -o dxbx-bootstrap.sh
chmod +x dxbx-bootstrap.sh
sh ./dxbx-bootstrap.sh
```

#What this procedure does

1. Downloads the `dxbx-bootstrap.sh` script to the current directory
2. Makes the script executable
3. Executes the bootstrap procedure, which performs the following steps:
  1. Checks for Bash 4, curl, and Docker, and prompts you to install any missing prerequisites
  2. Installs `dxbx` to `${XDG_BIN_HOME}` (defaults to `~/.local/bin/dxbx`) and adds it to your <code class="term">PATH</code>[<sup>🔖</sup>](#gloss-path) if not already present
4. Prints instructions to activate `dxbx` in your current terminal session
5. Cleans up by removing the downloaded `dxbx-bootstrap.sh` script

> **TIP:** When any script/command prompts for `[y/N]` or `[Y/n]`, it is requesting approval (`y` for _yes_; `n` for _no_). The capital letter indicates the default selection, so you can just press <kbd class="key">Enter</kbd> instead of typing the character to choose the default.

If `${XDG_BIN_HOME}` (or `~/.local/bin` if `XDG_BIN_HOME` is not set) is not yet in your <code class="term">PATH</code>[<sup>🔖</sup>](#gloss-path), the installer will prompt you to add it automatically; answer `y`.

Then activate it in your current session by running the `export` command it prints, or simply open a new terminal window.

<a id="step-initialize-your-project"></a>
### Step 2: Initialize your project (optional)
> **TIP:** [Skip this step](#step-test-dxbx) if your project is already configured for DocOps Box use. If you do not know, there is no harm in trying.
> **TIP:** It is always advised to stash or commit changes using Git before installing new software in any repository.
>
>
>
> ```
> git stash push -m "Stash before initializing DocOps Box"
> ```

In your project directory:

```
dxbx init
```

This downloads `docopsbox.yml` and `.env` into `.config/`, makes `.devcontainer/devcontainer.json`, prompts for a project slug, and updates `.gitignore` automatically.

**Check for new files**  
```
ls -a .config/ .devcontainer/
```

<a id="step-test-dxbx"></a>
### Step 3: Test dxbx with default image

To test that `dxbx` is working, run this command in your terminal:

```
dxbx ex docops info
```

You should see a nicely formatted readout of available tools and be returned to your host shell prompt.

#What was that?

The second half of the above command (`docops info`) is run inside any DocOps Box container for a readout of tool availability and versions.

The first half (`dxbx ex`) is the command for executing any command in a one-off container, which is created, run, and removed automatically.

<a id="step-container-workflow"></a>
### Step 4: Start working

When you need the tools provided by DocOps Box, invoke them _inside_ the container, not on your host system. Typically, you will likely wish to work _inside_ the container interactively, either in VS Code or dedicated terminal app.

Choose whichever entry point suits you; all give you the same environment, and of course you may alternate.

Try `dxbx up` to experience a full interactive shell session inside the container.

Use `dxbx vsc` to open a VS Code window with the containerized environment.

Or use `dxbx ex` to run any command in a fresh container and return to your host prompt immediately.

See the [next section](#usage) for more orientation and explanation of the different ways to work with your new environment.

<a id="usage"></a>
## Using Your New Environment

As much as DocOps Box tries to abstract away the complexities of Docker, some familiarity with the underlying concepts and commands is helpful for troubleshooting and advanced use.

There are also various ways to invoke these environments in your day-to-day work.

<a id="shell-cli-orientation"></a>
### Understanding Your Shells

The first thing that confuses new users is that you now have _two_ command environments to keep track of: the **host** shell (your normal terminal) and the **container** shell (the Linux environment inside Docker, where your tools actually live and run).

Your computer operating system or shell is the **host** system.

You are virtualizing a purpose-built Linux operating system in a **container** , which exploits your host’s Linux/Unix kernel but is carefully isolated from the rest of your system. Only directories that are mounted into the container are shared between host and container; everything else is separate and protected.

> **NOTE:** If you are using all of this inside WSL2 on Windows, ignore the fact that your Windows OS is also a host. For our purposes, the Linux shell you are running is your _host_, and Windows is your _OS_.

So while you may sometimes have two (or more) command prompts to consider, we will specify the _host_ (where you run `dxbx` commands) or the _container_ (where you run DocOps tools).

Instructions for any third-party Ruby or other CLI utilities (including other DocOps Lab apps) should be performed within a DocOps Box container.

**Mac and Linux users** have two layers:

```
Terminal app → container shell (Zsh)
   (host)
```

**Windows users via WSL2** have three layers; you are virtualizing twice:

```
Windows Terminal → WSL2 Linux shell → container shell (Zsh)
  (PowerShell) (host)
```

The important thing for **Windows users** : `dxbx` commands are typed in the **WSL2 shell** , not in PowerShell or a Windows Command Prompt. WSL2 _is_ your host for everything that follows.

Table 1. How you get into the container

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 20%;">
<col style="width: 40%;">
<col style="width: 40%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Method</th>
<th class="halign-left valign-top">How to enter</th>
<th class="halign-left valign-top">What happens to your prompt</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top"><strong>VS Code + Dev Containers</strong></td>
<td class="halign-left valign-top">Enter <code>dxbx vsc</code> in your <strong>host</strong> shell.
Or run VS Code through your OS, open a project, <kbd class="keyseq"><kbd class="key">Ctrl</kbd>+<kbd class="key">Shift</kbd>+<kbd class="key">P</kbd></kbd> then select <em>Dev Containers: Reopen in Container</em> if necessary</td>
<td class="halign-left valign-top">Terminal in the Dev Container window runs inside the container.</td>
</tr>
<tr>
<td class="halign-left valign-top"><strong>Interactive shell</strong></td>
<td class="halign-left valign-top">Enter <code>dxbx up</code> in your host shell</td>
<td class="halign-left valign-top">Your prompt changes to the container shell.
You stay there until you enter <code>exit</code>.</td>
</tr>
<tr>
<td class="halign-left valign-top"><strong>Get in and out</strong></td>
<td class="halign-left valign-top">Enter <code>dxbx ex</code> followed by any command in your host shell</td>
<td class="halign-left valign-top">Runs the command in a fresh container, prints the output, and removes the container.
No change to your prompt.</td>
</tr>
</tbody>
</table>

> **TIP:** Not sure which shell you are in? Run `hostname`. If it prints a short hex string (like `a3f9d2b1`), you are inside the container. If it prints your machine name, you are on the host.

Some programs you can run inside the container have their own interactive shells (like `irb` for Ruby or `node` for Node.js).

Use the following table to determine what to type to detect or exit a shell.

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 16.6666%;">
<col style="width: 50.0001%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Scenario</th>
<th class="halign-left valign-top">Prompt</th>
<th class="halign-left valign-top">Command</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top">Detect PowerShell (Windows only)</td>
<td class="halign-left valign-top"><code>PS C:\Users\name&gt;</code></td>
<td class="halign-left valign-top">You are in PowerShell, not yet in Linux.
Type <code>wsl</code> to enter your WSL2 shell.</td>
</tr>
<tr>
<td class="halign-left valign-top">Detect WSL2 shell (Windows only)</td>
<td class="halign-left valign-top"><code>username@hostname:~$</code></td>
<td class="halign-left valign-top">You are in WSL2 Linux.
Confirm with <code>uname -a</code>; the output will contain <code>microsoft</code> if you are in WSL2.</td>
</tr>
<tr>
<td class="halign-left valign-top">Exit WSL2 back to PowerShell (Windows only)</td>
<td class="halign-left valign-top"><code>username@hostname:~$</code></td>
<td class="halign-left valign-top">
<code>exit</code> returns you to the PowerShell prompt if you entered WSL2 by typing <code>wsl</code>.
If Windows Terminal opened WSL2 directly as a tab, <code>exit</code> closes the tab instead.</td>
</tr>
<tr>
<td class="halign-left valign-top">Detect container vs host</td>
<td class="halign-left valign-top"><code>appuser@work:/workspace%</code></td>
<td class="halign-left valign-top">
<code>hostname</code> prints a short hex string (container ID) if inside the container, or your machine name if on the host.</td>
</tr>
<tr>
<td class="halign-left valign-top">Exit container to host shell</td>
<td class="halign-left valign-top"><code>appuser@work:/workspace%</code></td>
<td class="halign-left valign-top">
<code>exit</code> (returns you to your host shell)</td>
</tr>
<tr>
<td class="halign-left valign-top">Exit <code>irb</code> to container shell</td>
<td class="halign-left valign-top"><code>irb(main):001&gt;</code></td>
<td class="halign-left valign-top">
<code>exit</code> or <kbd class="keyseq"><kbd class="key">Ctrl</kbd>+<kbd class="key">D</kbd></kbd>
</td>
</tr>
<tr>
<td class="halign-left valign-top">Exit <code>node</code> to container shell</td>
<td class="halign-left valign-top"><code>&gt;</code></td>
<td class="halign-left valign-top">
<code>exit</code> or <kbd class="keyseq"><kbd class="key">Ctrl</kbd>+<kbd class="key">D</kbd></kbd>
</td>
</tr>
<tr>
<td class="halign-left valign-top">Exit <code>python</code> to container shell</td>
<td class="halign-left valign-top"><code>&gt;&gt;&gt;</code></td>
<td class="halign-left valign-top">
<code>exit()</code> or <kbd class="keyseq"><kbd class="key">Ctrl</kbd>+<kbd class="key">D</kbd></kbd>
</td>
</tr>
</tbody>
</table>

<a id="volume-lifecycle"></a>
### Volume Lifecycle

DocOps Box uses named volumes[<sup>🔖</sup>](#gloss-volume) to persist data across sessions.

Your shell-command history is preserved in a volume that is used across all projects, so your command history is conveniently available for navigation and autocomplete.

Dependency packages are maintained for convenience, so they need not be reinstalled every time you start a session.

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

<a id="volume-management-commands"></a>
#### Volume Management Commands

If your volumes ever become problematic or stale for any reason, it is safe to remove the disposable ones, which will be recreated on demand.

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 28.5714%;">
<col style="width: 71.4286%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Command</th>
<th class="halign-left valign-top">Effect</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top"><code>dxbx stat</code></td>
<td class="halign-left valign-top">Show container state and volume sizes.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>dxbx wipe --vols</code></td>
<td class="halign-left valign-top">Remove the container and all per-project dependency volumes (Ruby gems, Node packages, Python venv); preserve shell history.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>dxbx wipe --hist</code></td>
<td class="halign-left valign-top">Remove dependency volumes <strong>and</strong> shell history (requires double confirmation).</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>dxbx back</code></td>
<td class="halign-left valign-top">Copy shell history to <code>~/.local/share/docopslab/dxbx/backups/</code> before destructive operations.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>dxbx back --restore</code></td>
<td class="halign-left valign-top">Restore shell history from a backup (append or replace).</td>
</tr>
</tbody>
</table>

<a id="image-overrides"></a>
### Per-invocation Image Overrides

In most cases, you will likely only need a single image for starting containers on your local machine. Thus, the main invocation commands will (`dxbx up`, `dxbx ex`) execute a container based on the default image.

In case you wish to use an alternate image/container, `dxbx up`, `dxbx ex`, and `dxbx pull` subcommands all accept an optional image specifier as their first argument. This selects the image for that invocation without editing any files.

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 40%;">
<col style="width: 60%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Form</th>
<th class="halign-left valign-top">Selects</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top">
<code>min</code> or <code>max</code>
</td>
<td class="halign-left valign-top">Variant only; context from config</td>
</tr>
<tr>
<td class="halign-left valign-top">
<code>work</code> or <code>live</code>
</td>
<td class="halign-left valign-top">Context only; variant from config</td>
</tr>
<tr>
<td class="halign-left valign-top">
<code>max:live</code>, <code>max live</code>
</td>
<td class="halign-left valign-top">Both variant and context</td>
</tr>
<tr>
<td class="halign-left valign-top">
<code>box-min</code>, <code>box-max</code>
</td>
<td class="halign-left valign-top">Same as <code>min</code>/<code>max</code> (the <code>box-</code> prefix is accepted)</td>
</tr>
</tbody>
</table>

> **NOTE:** It is not possible to run a `live` image in interactive mode. Live images are intended for one-off (`dxbx ex CMD`) commands.
<a id="example-commands"></a>
#### Example commands
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

Shell-level environment variables (`IMAGE_CONTEXT`, `IMAGE_VARIANT`) also perform this function.

> **NOTE:** If you alternate between Ruby versions, you will need to install dependencies for each version. The Bundler volume will remain the same, but the gems will be installed in separate subdirectories per Ruby version.

The settings for `PROJECT_SLUG` and `IMAGE_REGISTRY` can only be overridden via environment variables.

<a id="adding-dependencies"></a>
### Adding Runtime Dependencies

Inside the container, _do not_ install tools with one-off `gem install`, `npm install -g`, or `pip install` commands (even though it will work).

> **NOTE:** This also goes for shell programs._Avoid_ using `apt-get install` or similar dependency manager commands to add tools to the image. See [Extending DocOps Box](#extending) for how to add tools to a custom image if you need them available in the container without installing them every time.

Instead, declare any runtime libraries in a manifest file[<sup>🔖</sup>](#gloss-manifest) and let the package manager install the whole set. This best practice keeps your environment reproducible: anyone on your team (or a CI/CD operation) gets identical versions from the same manifest.

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 16.6666%;">
<col style="width: 16.6666%;">
<col style="width: 33.3333%;">
<col style="width: 33.3335%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Runtime</th>
<th class="halign-left valign-top">Manifest file</th>
<th class="halign-left valign-top">Install command</th>
<th class="halign-left valign-top">Notes</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top">Ruby</td>
<td class="halign-left valign-top"><code>Gemfile</code></td>
<td class="halign-left valign-top"><code>bundle install</code></td>
<td class="halign-left valign-top">Gems persist in the <code>docops-&lt;slug&gt;-bundle</code> named volume.
Add gems with <code>bundle add &lt;gem&gt;</code> or edit <code>Gemfile</code> directly.</td>
</tr>
<tr>
<td class="halign-left valign-top">Node.js</td>
<td class="halign-left valign-top"><code>package.json</code></td>
<td class="halign-left valign-top"><code>npm install</code></td>
<td class="halign-left valign-top">Packages persist in the <code>docops-&lt;slug&gt;-node</code> named volume.
Add packages with <code>npm install &lt;pkg&gt; --save</code>.</td>
</tr>
<tr>
<td class="halign-left valign-top">Python</td>
<td class="halign-left valign-top"><code>requirements.txt</code></td>
<td class="halign-left valign-top"><code>pip install -r requirements.txt</code></td>
<td class="halign-left valign-top">Packages persist in the <code>/opt/venv</code> named volume.
Add packages with <code>pip install &lt;pkg&gt;</code> then freeze: <code>pip freeze &gt; requirements.txt</code>.</td>
</tr>
</tbody>
</table>

These install commands run automatically at container creation inside VS Code. You only need to re-run them manually if you edit the manifest mid-session.

> **TIP:** If a tool you need is not available as a gem, npm package, or pip package, it may already be installed system-wide in the image (Pandoc, Vale, Git, etc.). Check with `which <tool>` before reaching for a package manager.

If your package files are committed in Git and you don’t want to force your whole team to install a tool you need temporarily, you can add it to the image with a custom image build or Dockerfile. See [Extending DocOps Box](#extending).

For the most part, the whole Docker-based approach of DocOps Box is intended to stick to a per-codebase strategy. While it is nice to have tools like Pandoc and Asciidoctor available anywhere in your host shell, it is best to designate application-specific runtime tools in the application’s manifest files.

If you do need more tools directly installed in a Docker image, consider [a custom image build](#extending).

<a id="open-server-port"></a>
### Open a server port

If your project includes a server component (like Jekyll’s `bundle exec jekyll serve` or Docusaurus’s `npm run serve`), you can expose the port to your host machine using properties in the _Docker_ configuration files (not your application’s `_config.yml`, `docusaurus.config.js`, etc).

**Uncomment and modify in `.config/docopsbox.yml`**  
```yaml
services:
  docops:
    ports:
      - "4005:4005"
```

For VS Code Dev Containers, the port also needs to be forwarded in the Dev Container configuration.

**Uncomment and modify in `.devcontainer/devcontainer.json`**  
```json
"forwardPorts": [4005]
```

Be sure the serve command inside the container is configured to bind at `0.0.0.0`, and the port is specified to match the forwarded port.

**Example Jekyll serve command with port and host binding**  
```
bundle exec jekyll serve --host 0.0.0 --port 4005
```

**Example Docusaurus serve command with port and host binding**  
```
npm run serve -- --build --host 0.0.0.0 --port 4005
```

Once the server is running, you can access it from your host machine at `http://localhost:4005` (or whatever port you forwarded).

<a id="configuration"></a>
## Configuration Reference

DocOps Box configuration involves 4 main files:

- `.config/.env` (committed to Git; non-secret configuration)
- `.config/.env.local` (not committed; secret configuration)
- `docopsbox.yml` (committed; Docker Compose configuration)
- `.devcontainer/devcontainer.json` (committed; VS Code Dev Container configuration)

By design, you may never need to touch these just to maintain a working environment. The `dxbx init` command sets them up for you, if you are starting a new project or adding DocOps Box to an existing project.

If you are joining a project, hopefully these files have been established and shared with you.

In cases where configuration tweaks are needed, most can be done in the `.env` or `.env.local` files, which are straightforward.

<a id="environment-variables-env"></a>
### Environment Variables (.config/.env)

The `.config/.env` file is committed to your repository. It contains only safe, non-secret project-specific configuration.

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 28.5714%;">
<col style="width: 14.2857%;">
<col style="width: 57.1429%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Variable</th>
<th class="halign-left valign-top">Default</th>
<th class="halign-left valign-top">Description</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top"><code>PROJECT_SLUG</code></td>
<td class="halign-left valign-top">see below</td>
<td class="halign-left valign-top">Short identifier used to name the per-project gem volume.
Set this to something unique across your projects.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>IMAGE_VARIANT</code></td>
<td class="halign-left valign-top"><code>max</code></td>
<td class="halign-left valign-top">
<code>max</code> (full toolset, adds Node.js and Python) or <code>min</code> (core docs tools: Ruby, Pandoc, Vale, Git).
Shell environment (Zsh vs Bash) is controlled by <code>IMAGE_CONTEXT</code>, not variant.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>IMAGE_CONTEXT</code></td>
<td class="halign-left valign-top"><code>work</code></td>
<td class="halign-left valign-top">
<code>work</code> (interactive, OhMyZsh) or <code>live</code> (automation, Bash only).</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>RUBY_VERSION</code></td>
<td class="halign-left valign-top">(unset)</td>
<td class="halign-left valign-top">Selects a specific Ruby version.
Omit (or leave unset) to use the default (3.3).</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>IMAGE_REGISTRY</code></td>
<td class="halign-left valign-top"><code>docopslab</code></td>
<td class="halign-left valign-top">Docker Hub username or registry prefix for the image.</td>
</tr>
</tbody>
</table>

The `PROJECT_SLUG` environment variable is used to create unique volume names for each project, so that dependencies installed in one project do not interfere with those in another. It defaults to the parent directory name, but you can set it to any short identifier you like.

> **NOTE:** `RUBY_VERSION` also controls which pre-built image tag is pulled from Docker Hub. Set it to select a non-default Ruby version without rebuilding anything.

<a id="secret-environment-variables-env-local"></a>
### Secret Environment Variables (.config/.env.local)

The `.config/.env.local` file is created during `dxbx init`.

Uncomment values as needed. This file is never committed to Git.

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 25%;">
<col style="width: 75%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Variable</th>
<th class="halign-left valign-top">Use</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top"><code>HOST_UID</code></td>
<td class="halign-left valign-top">Override the <span class="term">UID</span><a href="#gloss-uid-gid"><sup>🔖</sup></a> used for file ownership inside the container.
Set to match <code>id -u</code> on the host if you see permission errors.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>HOST_GID</code></td>
<td class="halign-left valign-top">Same as above for group ID (<code>id -g</code>).</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>IMAGE_REGISTRY</code></td>
<td class="halign-left valign-top">Override to a private registry or local mirror.</td>
</tr>
</tbody>
</table>

<a id="project-slug-resolution"></a>
### Project Slug Resolution Order

The `dxbx` utility resolves the `PROJECT_SLUG` in this order:

1. `PROJECT_SLUG` from `.config/.env` or `.config/.env.local`, if present, or else
2. `:this_proj_slug:` AsciiDoc attribute in `README.adoc`, if present, or else
3. current directory name (spaces and underscores to hyphens, all lowercased)

<a id="image-variants-contexts"></a>
### Image Variants and Contexts

The image tag format is: `<registry>/box-<variant>:<context>` or, for a specific Ruby version, `<registry>/box-<variant>:<context>-<ruby>`.

For example: `docopslab/box-max:work` or `docopslab/box-max:work-3.4`

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 20%;">
<col style="width: 20%;">
<col style="width: 60%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Setting</th>
<th class="halign-left valign-top">Values</th>
<th class="halign-left valign-top">Notes</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top"><code>IMAGE_VARIANT</code></td>
<td class="halign-left valign-top">
<code>max</code>, <code>min</code>
</td>
<td class="halign-left valign-top">
<code>min</code> includes Ruby, Bundler, Git, Pandoc, and Vale.
<code>max</code> adds Node.js, Python, and auxiliary tools.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>IMAGE_CONTEXT</code></td>
<td class="halign-left valign-top">
<code>work</code>, <code>live</code>
</td>
<td class="halign-left valign-top">
<code>work</code> configures Zsh with Oh My Zsh for interactive daily use;
<code>live</code> uses Bash only, with no interactive enhancements; suited for CI/CD automation.</td>
</tr>
<tr>
<td class="halign-left valign-top"><code>RUBY_VERSION</code></td>
<td class="halign-left valign-top">
<code>3.3</code>, <code>3.4</code>
</td>
<td class="halign-left valign-top">Selects a specific published Ruby version; omit to use the default (3.3).
Setting this appends the version to the context tag: <code>work</code> becomes <code>work-3.4</code>.</td>
</tr>
</tbody>
</table>

<a id="compose-config"></a>
### Docker Compose Configuration (docopsbox.yml)

The `.config/docopsbox.yml` file is the single source of truth for the container structure. Both `dxbx` and `.devcontainer/devcontainer.json` reference it, and `docopsbox.yml` in turn references `.config/.env` and `.config/.env.local` as needed.

<a id="key-compose-config"></a>
#### Key configuration

- `env_file:` loads `.env` first, then `.env.local` (`required: false`; no error if absent; both resolved relative to `.config/`)
- Service name: `docops`; container name: `docopsbox_${PROJECT_SLUG}`
- Volume names embed `PROJECT_SLUG` for per-project isolation
- Working directory inside the container: `/workspace`

<a id="devcontainer-config"></a>
### VS Code Dev Container Configuration (.devcontainer/devcontainer.json)

The `.devcontainer/devcontainer.json` file configures how VS Code connects to the container. Hopefully, you should never need to edit this file, as it references `docopsbox.yml` for all relevant configuration.

Use the [Development Containers standard documentation](https://containers.dev/implementors/json_reference/) for any necessary tweaks or troubleshooting.

<a id="troubleshooting"></a>
## Troubleshooting
<a id="start-with-diagnostics"></a>
### Start with Diagnostics

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
- Actionable error messages for common failure conditions

<a id="common-issues"></a>
### Common Issues

<dl>
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
Native gem extensions (compiled C code inside gems like `nokogiri` or `ffi`) are compiled for a specific Ruby version. If the image’s Ruby version changes and you are using a cached gem bundle volume, the extensions will be incompatible.

Clear the bundle volume and reinstall:

```
dxbx wipe --vols
dxbx up
# Inside the container:
bundle install
```

If you are not sure which Ruby version the cached bundle was built against, `dxbx stat` shows the current image’s Ruby version.
</dd>
<dt>5: VS Code Dev Container fails to start</dt>
<dd>
1. Verify Docker is running: `docker info`
2. Validate the Compose file: `docker compose config`
3. Open the Dev Container log: Command Palette → _Dev Containers: Show Container Log_
</dd>
<dt>6: WSL2: very slow file I/O</dt>
<dd>
Ensure your project directory lives inside the WSL2 filesystem (`~/…​`), not on the Windows mount (`/mnt/c/…​`). Windows filesystem mounts have significantly degraded I/O performance under WSL2.
</dd>
</dl>

<a id="extending"></a>
## Extending DocOps Box

This advanced topic is only cursorily covered here, but DocOps Box is designed to be extended and customized in various ways.

There are several currently undocumented features, including the use of pre- and post-build scripts and serial image builds with custom Dockerfiles.

This section will grow as real-world conditions prove out use cases.

<a id="custom-image-builds"></a>
### Custom Image Builds

The `Dockerfile` used to build supported images is highly configurable. It accepts lots of arguments for a custom build.

You will want to clone the DocOps/box repository and run `docker build` inside it.

> **NOTE:** This means you will need Git installed directly on your host ([MacOS](#macos-dependencies) | [Linux/WSL](#linux-dependencies)).
<a id="build-arg-directives"></a>
#### Use docker build arguments

1. Clone the repo (outside your project directories).

1. With SSH:

2. Without SSH:

The `-t` argument tags the image. The `.` as the last argument indicates that the `Dockerfile` is in the current directory.

See the `ARG` directives in the base [`Dockerfile`](https://github.com/DocOps/box/tree/latest/Dockerfile) for all available build arguments.

<a id="quickie-builds-dxbx"></a>
#### Quickie builds with dxbx commands

The `dxbx` utility, executed in the DocOps Box repository codebase, can build several custom permutations locally.

The format is:

```
[EXTRA_ARGS].bin/dxbx make [variant] [context] [ruby_version]
```

<dl>
<dt>Example image build commands</dt>
<dd>
**Builds `docopslab/box-min:work` with Ruby 4.0**  
```
./bin/dxbx make 4.0 min work
```

**Builds `docopslab/box-max:live` with Ruby 4.0 and Node.js**  
```
ADD_NODEJS=true NODEJS_VERSION=26 ./bin/dxbx make min live 4.0
```
</dd>
</dl>

<a id="custom-images-dxbx-devcontainers"></a>
#### Use a custom image with dxbx and Dev Containers

If you do build a custom image with additional software pre-installed, you can run it from anywhere using a complete `docker run` command. For instance:

```
docker run --rm -it -v $PWD:/workspace docopslab/custom:work asciidoctor -o readme.html -a doctype=book README.adoc
```

If you want to use `dxbx` commands and/or wish to share it with your team, do the following.

1. Keep the image tag consistent with its closest DocOps Box variant, but use your organization’s own registry prefix.

2. Host the image on [DockerHub](https://hub.docker.com).
3. Change the `registry` property in your `.env` to point to your account instead of `docopslab`.

This should execute `dxbx` commands on images sourced and built as you choose.

<a id="appendices"></a>
## Appendices
<a id="who-for"></a>
### Appendix A: Who is This Software For?

I made the DocOps Box toolkit **for people who want to learn** my preferred document operations automation tools but who do not yet want to deal with properly installing and maintaining Ruby, Node.js, Python, Pandoc, Vale, Git, and more on their system.

_If you are less technical than programmers_ but bolder and more experienced than most peers in your profession, this entire project is geared toward getting you up and running with tools to bridge the gap.

This solution also provides an environment to share amongst your team, or even to use on a production server or continuous-integration/deployment process, without everyone having to install all the dependencies one by one.

_If you are working solo_, it’s even simpler to get started. Install the prerequisites, install `dxbx`, and run `dxbx init` in your project directory. The default setting should work for you, and you can start running commands right away.

> **TIP:** Once you are working regularly with these technologies, it may well make sense to set up a proper development environment locally, especially if you find yourself directly invoking command-line tools frequently for similar or parallel projects. This guide provides [instructions for doing just this on all three major operating systems](#ruby-for-real).

The repo includes a command-line application (`dxbx`), mainly for simplifying Docker commands.

Docker is an incredibly powerful and somewhat complicated piece of software, but we use it in specific ways that do not require mastery or even a full grasp of what Docker is and does. More importantly, the `dxbx` script simplifies the commands you will need to run for this specific Docker use case, without pretending to be a broad controller for other Docker use cases.

This “abstraction” manages Docker images and containers such that the running container will:

- reflect your <strong class="term">host</strong> <strong class="term">workstation</strong> user and group, Git config, and SSH keys
- work seamlessly with your local Git environment if you already have one
- write to your own (host/workstation) filesystem so your work remains available when the container shuts down
- persist the state of your project, including dependencies and command history, across container restarts

<a id="glossary"></a>
### Appendix B: Glossary

Terms of art used throughout this document and the broader “DocOps”/docs-as-code domain.

<a id="glossary-jargon"></a>
#### Domain jargon and idioms

<dl>
<dt>docs-as-code</dt>
<dd>
A set of practices for managing _technical documentation_ with the same tools and workflows as software development. This includes using version control (Git), writing in lightweight markup formats (like AsciiDoc or Markdown), and automating builds and deployments with CI/CD pipelines. The goal is to treat documentation as a first-class citizen in the development process, improving collaboration, versioning, and quality.
</dd>
</dl>

<dl>
<dt>DocOps</dt>
<dd>
Short for _document operations_, a set of practices and tools for managing technical documentation with the same (or analogous) techniques and tools as software development.

DocOps tends to be focused on automation and tooling; it pertains to “practitioner services” aspect of the _docs-as-code_ practice. **DocOps Box** is so-called as it aims to assist document operators by providing the underlying infrastructure for executing a docs-as-code workflow.
</dd>
</dl>

<dl>
<dt>bootstrap</dt>
<dd>
A process for rapidly initializing or instantiating a project/codebase from minimal inputs. The process typically involves “inflating” files from templates and applying enough configuration to enable basic/nascent operations.

In the world of CLI tools and shell environments, “bootstrapping” often means performing an `init` command that writes files and prepares for or executes a first invocation of whatever program is being set up.
</dd>
</dl>

<dl>
<dt>technical documentation</dt>
<dd>
Documents that are structured, versioned, highly semantic, single sourced, divergently delivered, _or_ otherwise complex to the extent of requiring special handling for the _management_, _maintenance_, or automated/repeat _publishing_. This includes legal documents, standards specifications, product requirements, reference materials, non-linear narratives, curriculum, as well as any “living” document, collaboratively authored material, or anything intended to diverge from but maintain association with a prime or peer document.
</dd>
</dl>

<dl>
<dt>tech stack</dt>
<dd>
The core, categorical or platform-level components of a project or workflow. DocOps Box is optimized for an AsciiDoc, YAML, and Liquid tech stack.
</dd>
</dl>

<dl>
<dt>toolchain</dt>
<dd>
A set of software tools that work together to accomplish a task. In the context of DocOps Box.
</dd>
</dl>

<a id="glossary-docker"></a>
#### Docker and container concepts

<dl>
<dt>Docker image</dt>
<dd>
A read-only, pre-built package containing an operating system layer and pre-installed software. When you run an image, Docker creates a live [container](#gloss-container) from it. DocOps Box provides several pre-built images tagged by variant and [context](#gloss-image-tag) (for example, `box-max:work`).
</dd>
</dl>

<dl>
<dt>container</dt>
<dd>
A running instance of a Docker [image](#gloss-image). The container is isolated from your host system but can read and write files through a [bind mount](#gloss-bind-mount). When the container stops, any changes made outside of mounted paths or [named volumes](#gloss-volume) are discarded.
</dd>
</dl>

<dl>
<dt>named volume</dt>
<dd>
A persistent storage area managed by Docker, separate from both your project directory and the container’s own filesystem. DocOps Box uses named volumes to store installed dependencies (Ruby gems, Node packages, Python packages) and your command history, so they survive container restarts. Unlike a [bind mount](#gloss-bind-mount), a named volume is invisible on the host; its contents are accessible only from inside a container.
</dd>
</dl>

<dl>
<dt>bind mount</dt>
<dd>
A direct link between a directory on your [host](#gloss-host) and a path inside the container. DocOps Box bind-mounts your project directory to `/workspace` so your files are accessible inside the container without copying. Changes on either side are immediately reflected on the other.
</dd>
</dl>

<dl>
<dt>Docker Hub</dt>
<dd>
Docker’s public registry for sharing and downloading container images. DocOps Box pre-built images are hosted there under the `docopslab` organization. When you pull an image for the first time, Docker Hub is the source.
</dd>
</dl>

<dl>
<dt>registry</dt>
<dd>
A server that stores and distributes Docker [images](#gloss-image). Docker Hub is the default public registry. The `IMAGE_REGISTRY` variable lets you specify a private or alternate registry.
</dd>
</dl>

<dl>
<dt>image tag</dt>
<dd>
The label appended after the colon in an image name. For example, the `work` in `docopslab/box-max:work`. Tags identify the specific variant, version, or configuration of an image.
</dd>
</dl>

<dl>
<dt>Docker Compose</dt>
<dd>
A tool for defining and running Docker containers using a YAML configuration file. DocOps Box uses a minimal Compose file (`docopsbox.yml`) so that container configuration (volumes, environment variables, user IDs) is version-controlled and shareable across a team.
</dd>
</dl>

<a id="glossary-system-shell"></a>
#### System and shell concepts

<dl>
<dt>host / host system</dt>
<dd>
Your computer’s own operating system and filesystem; the environment you are in before entering a container. Commands like `dxbx up` are host commands. Commands like `bundle install` run inside the container, not on the host.
</dd>
</dl>

<dl>
<dt>shell</dt>
<dd>
A program that accepts text commands and passes them to the operating system to execute. Bash and Zsh are both shells. When you open a terminal, you are running inside a shell. DocOps Box `work` images use Zsh with OhMyZsh; `live` images use Bash.
</dd>
</dl>

<dl>
<dt>PATH</dt>
<dd>
An environment variable that lists the directories your shell searches when you enter a command name. If `dxbx` cannot be found after installation, your PATH does not yet include the installation directory: `${XDG_BIN_HOME}` (which defaults to `~/.local/bin` if `XDG_BIN_HOME` is not set).`dxbx install` will offer to add the required line to your shell profile automatically.
</dd>
</dl>

<dl>
<dt>UID / GID</dt>
<dd>
Representing _user identifier_ and _group identifier_, numbers the Linux kernel uses to track file ownership and access permissions. Every file belongs to a UID and a GID. If files the container writes appear as owned by an unexpected user, set `HOST_UID` and `HOST_GID` in `.config/.env.local` to match the output of `id -u` and `id -g` on your host.
</dd>
</dl>

<dl>
<dt>SSH / SSH agent</dt>
<dd>
SSH (_secure shell_) is the protocol used for encrypted communication between computers, including authenticating to GitHub for pushing and pulling code. The **SSH agent** is a background process that holds your decrypted SSH keys so you do not have to type your passphrase repeatedly.

Executing `dxbx up` automatically forwards the host SSH agent into the container when `SSH_AUTH_SOCK` is set in the host shell. SSH agent forwarding in VS Code Dev Containers requires per-OS configuration; see the comments in `.devcontainer/devcontainer.json`.
</dd>
</dl>

<dl>
<dt>entrypoint script</dt>
<dd>
A script that runs automatically each time a container starts, before the main process. DocOps Box’s entrypoint detects the `HOST_UID` and `HOST_GID` environment variables and adjusts the container user’s identity to match, ensuring files you create inside the container are owned by you on the host.
</dd>
</dl>

<dl>
<dt>postCreateCommand</dt>
<dd>
A VS Code Dev Containers configuration hook that specifies a command to run automatically the first time a container is created. DocOps Box uses it to run `bundle install`, `npm install`, and `pip install` so declared dependencies are ready immediately after the container starts, without any manual step.
</dd>
</dl>

<a id="glossary-runtime-dependency"></a>
#### Runtime and dependency management

<dl>
<dt>runtime / runtime environment</dt>
<dd>
The software layer responsible for executing programs written in a specific language. Ruby, Node.js, and Python each have a corresponding runtime that must be installed to execute programs written in that language. DocOps Box images bundle the runtimes you need so you do not have to install them individually on your host.
</dd>
</dl>

<dl>
<dt>dependency manifest file</dt>
<dd>
A document that declares a project’s dependencies and (optionally) the specific versions required. Examples: `Gemfile` (Ruby), `package.json` (Node.js), `requirements.txt` (Python). A [dependency manager](#gloss-dependency-manager) reads the manifest to install exactly the right packages.
</dd>
</dl>

<dl>
<dt>dependency manager / package manager</dt>
<dd>
A tool that reads a [manifest file](#gloss-manifest) and installs the listed packages at compatible versions. Examples: Bundler (`bundle install`) for Ruby, npm for Node.js, pip for Python. In DocOps Box, installed packages are stored in [named volumes](#gloss-volume) so they survive container restarts.
</dd>
</dl>

<dl>
<dt>gem</dt>
<dd>
A Ruby software package, distributed via RubyGems and managed by Bundler. When you run `bundle install`, Bundler reads your `Gemfile` and installs the declared gems into the project’s named volume.
</dd>
</dl>

<dl>
<dt>version manager</dt>
<dd>
A tool that allows multiple versions of a runtime (Ruby, Node.js, Python) to coexist on a single machine and be switched per project. Examples: rbenv and RVM for Ruby; nvm for Node.js; pyenv for Python. DocOps Box handles versioning through its pre-built images. Version managers are only relevant if you install runtimes directly on the host.
</dd>
</dl>

<a id="glossary-abbreviations-tooling"></a>
#### Abbreviations and tooling terms

<dl>
<dt>CI/CD</dt>
<dd>
Stands for _continuous integration/continuous deployment_ (or _delivery_), an automated pipeline that builds, tests, and optionally publishes your project every time you push/merge changes into the main branch. DocOps Box `live` images are designed for use in CI/CD environments.
</dd>
</dl>

<dl>
<dt>CLI</dt>
<dd>
Short for _command-line interface_. Refers to any prompt-based program you interact with by typing commands into a terminal, as opposed to clicking through a graphical presentation. Most tools in the DocOps ecosystem are CLI tools. CLI is effectively a superset which includes _TUI_ applications.
</dd>
</dl>

<dl>
<dt>GUI</dt>
<dd>
Short for _graphical user interface_, a program that presents interactive visual elements like windows, buttons, and menus. Most terminal apps are “GUIs”; CLIs run inside the terminal interface, but the app offers menus, tabs, or other external visual elements.
</dd>
</dl>

<dl>
<dt>TUI</dt>
<dd>
For _text-based user interface_. An application that runs inside a terminal but presents a structured, screen-filling layout; more than a plain command prompt, less than a graphical window. The text editors included in DocOps Box images, nano and Vim, are TUI applications.
</dd>
</dl>

<dl>
<dt>OAS / OpenAPI Specification</dt>
<dd>
A standard machine-readable format for describing or defining REST APIs (formerly named Swagger). OAS documents (OAD) are typically written in YAML and used to generate API documentation, client libraries, and testing regimens.
</dd>
</dl>

<dl>
<dt>IDE</dt>
<dd>
Stands for _integrated development environment_, an application that combines a code editor with tools for navigating, building, and debugging software. VS Code is the IDE recommended by DocOps Box; it integrates with Docker through the Dev Containers extension.
</dd>
</dl>

<a id="auxiliary-tools"></a>
### Appendix C: Auxiliary Tools

The following tools are available inside every `*max:work` image:

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 22.2222%;">
<col style="width: 44.4444%;">
<col style="width: 33.3334%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Tool</th>
<th class="halign-left valign-top">Purpose</th>
<th class="halign-left valign-top">CLI</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top"><a href="https://asciidoctor.org" target="_blank" rel="noopener">Asciidoctor</a></td>
<td class="halign-left valign-top">Converts <code>.adoc</code> to HTML, PDF, and more</td>
<td class="halign-left valign-top">
<code>asciidoctor</code>, <code>asciidoctor-pdf</code>
</td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://github.com/asciidoctor/kramdown-asciidoc" target="_blank" rel="noopener">Kramdown-AsciiDoc</a></td>
<td class="halign-left valign-top">Converts <code>.md</code> to <code>.adoc</code>
</td>
<td class="halign-left valign-top"><code>kramdoc</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://nokogiri.org" target="_blank" rel="noopener">Nokogiri</a></td>
<td class="halign-left valign-top">Parsees and manipulates HTML and XML</td>
<td class="halign-left valign-top"><code>nokogiri</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://github.com/rtomayko/tilt" target="_blank" rel="noopener">Tilt</a></td>
<td class="halign-left valign-top">Renders ERB, Liquid, and many more template formats</td>
<td class="halign-left valign-top"><code>tilt</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://pandoc.org" target="_blank" rel="noopener">Pandoc</a></td>
<td class="halign-left valign-top">Document conversion/migration</td>
<td class="halign-left valign-top"><code>pandoc</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://vale.sh" target="_blank" rel="noopener">Vale CLI</a></td>
<td class="halign-left valign-top">Linting and style checking</td>
<td class="halign-left valign-top"><code>vale</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://redocly.com/docs/cli" target="_blank" rel="noopener">Redocly CLI</a></td>
<td class="halign-left valign-top">OpenAPI validation and docs generation</td>
<td class="halign-left valign-top"><code>redocly</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://www.speakeasy.com/docs/speakeasy-reference/cli" target="_blank" rel="noopener">Speakeasy CLI</a></td>
<td class="halign-left valign-top">OpenAPI validation and mock servers</td>
<td class="halign-left valign-top"><code>speakeasy</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://quobix.com/vacuum/" target="_blank" rel="noopener">Vacuum</a></td>
<td class="halign-left valign-top">OpenAPI document manipulation</td>
<td class="halign-left valign-top"><code>vacuum</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://www.libreoffice.org" target="_blank" rel="noopener">LibreOffice CLI tools</a></td>
<td class="halign-left valign-top">Document conversion and manipulation</td>
<td class="halign-left valign-top">
<code>soffice</code>, <code>unoserver</code>
</td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://jqlang.org" target="_blank" rel="noopener">jq</a></td>
<td class="halign-left valign-top">Command-line JSON processor</td>
<td class="halign-left valign-top"><code>jq</code></td>
</tr>
<tr>
<td class="halign-left valign-top"><a href="https://mikefarah.gitbook.io/yq/" target="_blank" rel="noopener">yq</a></td>
<td class="halign-left valign-top">Command-line YAML processor</td>
<td class="halign-left valign-top"><code>yq</code></td>
</tr>
</tbody>
</table>

These are container-shell commands. From your host terminal, use `dxbx up` to start an interactive container session and then invoke tools at the prompt, or use `dxbx ex <command>` to run a single tool directly without entering the container shell.

<a id="sample-cmds-asciidoctor"></a>
#### Sample Commands: Asciidoctor
**Convert all `.adoc` files under `docs/` into `build/`**  
```
asciidoctor -R docs -D _build docs/**/*.adoc
```

**Generate a styled, navigable manual (TOC, numbered sections)**  
```
asciidoctor -a toc=left -a sectnums \
 -a source-highlighter=rouge -o _build/manual.html \
 README.adoc
```

**Produce a PDF from a single AsciiDoc source**  
```
asciidoctor-pdf -a toc -a pagenums -o _pubs/manual.pdf manual.adoc
```

<a id="sample-cmds-kramdoc"></a>
#### Sample Commands: Kramdown-AsciiDoc
**Convert a Markdown file to AsciiDoc**  
```
kramdoc -o README.adoc README.md
```

<a id="sample-cmds-liquid"></a>
#### Sample Commands: Nokogiri

Use [Nokogiri’s CLI mode](https://nokogiri.org) to parse and manipulate HTML and XML documents.

**Count significant headings in a remote page**  
```
nokogiri https://docopslab.org/docs/contributing/ \
 -e 'puts $_.css("h1,h2,h3").count'
```

**List all links on a page (text + URL)**  
```
nokogiri https://docopslab.org/docs/contributing/ \
  -e '$_.css("a[href]").each { |a| puts "#{a.text.strip}\t#{a["href"]}" }'
```

<a id="sample-cmds-vale"></a>
#### Sample Commands: Tilt

Use [Tilt’s CLI mode](https://github.com/rtomayko/tilt) to render templates in various formats.

**Test rendering of inline templates**  
```
echo 'Hello, <%= name %>!' | tilt -t erb --vars='{name: "world"}'
echo 'Hello, {{ name }}!' | tilt -t liquid --vars='{name: "world"}'
```

**List all available engines**  
```
tilt --list
```

<a id="sample-cmds-redocly"></a>
#### Sample Commands: Redocly CLI

The [Redocly CLI](https://redocly.com/docs/cli) provides utilities for working with OpenAPI documents.

**Validate an OpenAPI document**  
```
redocly lint api.yaml
```

**Generate static HTML API docs**  
```
redocly build-docs api.yaml -o _build/api-docs.html
```

<a id="sample-cmds-libreoffice"></a>
#### LibreOffice tools

The LibreOffice tooling in `work` containers is primarily intended for use in CI/CD pipelines, where you can invoke the `live` image directly with `docker run` or via `dxbx ex` to perform conversions and other operations on demand.

> **WARNING:** This section is entirely generated using Lumo LLM, and has not been verified for accuracy. My clients sometimes need these tools, but I have not worked with them.
<a id="libreoffice-cli-comparison"></a>
##### Key capabilities comparison

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Feature</th>
<th class="halign-left valign-top">soffice</th>
<th class="halign-left valign-top">unoserver</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top">Document opening/creation</td>
<td class="halign-left valign-top">✅ Full support</td>
<td class="halign-left valign-top">❌ Not directly</td>
</tr>
<tr>
<td class="halign-left valign-top">File conversion</td>
<td class="halign-left valign-top">✅ <code>--convert-to</code>
</td>
<td class="halign-left valign-top">✅ Via server API</td>
</tr>
<tr>
<td class="halign-left valign-top">Print operations</td>
<td class="halign-left valign-top">✅ <code>-p</code>, <code>--pt</code>, <code>--print-to-file</code>
</td>
<td class="halign-left valign-top">❌ Not directly</td>
</tr>
<tr>
<td class="halign-left valign-top">Headless mode</td>
<td class="halign-left valign-top">✅ <code>--headless</code>
</td>
<td class="halign-left valign-top">✅ Implicit (daemon mode)</td>
</tr>
<tr>
<td class="halign-left valign-top">Network/API access</td>
<td class="halign-left valign-top">⚠️ Via <code>--accept</code>
</td>
<td class="halign-left valign-top">✅ Built-in XMLRPC/UNO servers</td>
</tr>
<tr>
<td class="halign-left valign-top">Daemon/background mode</td>
<td class="halign-left valign-top">❌ Limited</td>
<td class="halign-left valign-top">✅ <code>--daemon</code> flag</td>
</tr>
<tr>
<td class="halign-left valign-top">Request limits</td>
<td class="halign-left valign-top">❌ No</td>
<td class="halign-left valign-top">✅ <code>--stop-after</code>
</td>
</tr>
<tr>
<td class="halign-left valign-top">Conversion timeouts</td>
<td class="halign-left valign-top">❌ No</td>
<td class="halign-left valign-top">✅ <code>--conversion-timeout</code>
</td>
</tr>
<tr>
<td class="halign-left valign-top">Logging control</td>
<td class="halign-left valign-top">✅ <code>-f</code>, <code>--verbose</code>, <code>--quiet</code>
</td>
<td class="halign-left valign-top">✅ Same options</td>
</tr>
<tr>
<td class="halign-left valign-top">Port configuration</td>
<td class="halign-left valign-top">❌ Manual via <code>--accept</code>
</td>
<td class="halign-left valign-top">✅ <code>--port</code>, <code>--uno-port</code>
</td>
</tr>
</tbody>
</table>

<table class="frame-all grid-all stretch">
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead><tr>
<th class="halign-left valign-top">Operation</th>
<th class="halign-left valign-top">soffice</th>
<th class="halign-left valign-top">unoserver</th>
</tr></thead>
<tbody>
<tr>
<td class="halign-left valign-top">Print to PDF</td>
<td class="halign-left valign-top"><code>soffice --headless --print-to-file output.pdf input.doc</code></td>
<td class="halign-left valign-top">❌</td>
</tr>
<tr>
<td class="halign-left valign-top">Batch processing</td>
<td class="halign-left valign-top">Looping <code>soffice</code> calls in a script</td>
<td class="halign-left valign-top">
<code>unoserver --daemon</code> + API calls for each file</td>
</tr>
<tr>
<td class="halign-left valign-top">CI/CD pipelines</td>
<td class="halign-left valign-top">
<code>soffice</code> invoked in build scripts</td>
<td class="halign-left valign-top">✅ <code>unoserver</code> running as a service, API calls in build scripts</td>
</tr>
<tr>
<td class="halign-left valign-top">Scripted migration</td>
<td class="halign-left valign-top">✅ <code>soffice --convert-to</code> in a script</td>
<td class="halign-left valign-top">
<code>unoserver</code> API calls for conversion in a script</td>
</tr>
</tbody>
</table>

<a id="soffice-use-cases"></a>
##### Use soffice for:

- Converting files in a simple script (`--convert-to pdf *.doc`)
- Printing documents directly
- Running occasional batch operations
- Executing macros on specific files
- Quick one-off document operations

<a id="unoserver-use-cases"></a>
##### Use unoserver when you need:

- A persistent service handling multiple conversion requests
- Centralized logging and monitoring
- Timeout protection for stuck conversions
- To build an application that programmatically calls LibreOffice
- To limit resource usage (`--stop-after`, `--conversion-timeout`)
- Network-accessible document conversion

<a id="sample-cmds-soffice-unoserver"></a>
##### Sample LibreOffice commands
**Convert a Word document to PDF with `soffice`**  
```
soffice --headless --convert-to pdf input.doc
```

**Execute a macro on a document**  
```
soffice --headless "macro:///Standard.Module1.MyMacro(input.doc)"
```

**Convert a batch of mixed text/docs to ODT**  
```
soffice --headless \
  --convert-to odt \
  --outdir /workspace/output \
  /workspace/input/*.txt /workspace/input/*.docx
```

**Start unoserver in the background**  
```
unoserver \
  --interface 127.0.0.1 \
  --uno-interface 127.0.0.1 \
  --port 2003 \
  --uno-port 2002 \
  > /workspace/unoserver.log 2>&1 &
```

**Convert a document to PDF using unoserver's API**  
```
unoconvert \
  --host 127.0.0.1 \
  --port 2003 \
  --convert-to pdf \
  /workspace/test_in/sample2.docx \
  /workspace/test_out/sample2.uno.pdf
```

**Stop unoserver**  
```
kill "$UNOSERVER_PID"
wait "$UNOSERVER_PID" 2>/dev/null || true
```

<a id="ruby-for-real"></a>
### Appendix D: Installing Everything to Host

Are you ready to install Ruby and other tools on <strong class="term workstation">your workstation</strong> or another <strong class="term">host</strong> so you can stop messing with Docker and `dxbx`?

> **TIP:** If you already know you want to install some or all software directly to your host, [skip to the nuts and bolts](#native-ruby). The next few sections are for helping you decide.

Whatever your operating system, you are going to have to roll up your sleeves and take several steps. Over time, you will also need to actively configure and periodically upgrade most of what you install here; this is the reality of maintaining a “development environment” on your workstation.

> **NOTE:** Windows users are still advised to perform Ruby/runtime-centric commands on Linux via WSL2, so these instructions focus on that approach rather than a native Windows install.

Zsh and Git should be more straightforward, if you are not already using them directly on your host workstation.

Ruby can be a bit trickier, but my clients have found this method not to be too frustrating on both MacOS and Linux, including Linux via WSL2 on Windows.

Node.js, Python, and Pandoc are also relatively simple to install and set up, and all three are very likely to be required or at least helpful in your career using developer tools to manage documents and documentation.

For these reasons, you _may_ be well advised to “bite the bullet” and install everything directly on your host, skipping or abandoning Docker, or using it case by case.

> **IMPORTANT:** Host-side installation does _not_ preclude concurrent usage via Docker. You can use pretty much any mix of native installs and Docker-based fallbacks.

Then again, maybe this is more than you wish to manage.

<a id="why-not"></a>
#### Why Not?

Let’s go over why you might _not_ want to move away from the Docker method.

If the Docker method is working for you, there may be no real reason to switch.

The Docker method might be almost _necessary_ where lots of frequently changing dependencies are being managed. In fact, if you are already working with a modified `docopsbox.yml` shared among multiple users, you are probably experiencing the advantages of standardizing around a shared container toolchain: containers that start identically every time, with common commands.

If you are working with someone who is constantly developing Ruby-based tools, they are responsible for helping keep your environment up to date. Especially across multiple runtimes (mixing Python, JavaScript, or who-knows-what in a larger project), containerization may be the only way to keep up.

My own work should not require many changes in this regard, so if you’re following my advice longer term, at least in my case, the whole point is to hopefully keep the `dxbx` script/`box` images combination relevant and useful to all my clients.

If the work you’re doing depends entirely on Ruby and shell commands, the Docker method offers less advantage, even though that is also foremost what it is designed for.

> **TIP:** Having Git installed on your workstation (host) probably does have big advantages and really no downside. Having it installed on your host will not conflict with the Git installation in the DocOps Box Docker image, either.

If you are using multiple Docker containers or a heavily adapted version of `dxbx`, it will likely be harder to reproduce and maintain what Docker does for you currently.

In short, if you have not been told to install Ruby, Node.js, Python, Pandoc, and the like directly to host, you probably do not need to.

> **TIP:** If you find yourself comfortable using containers run through `dxbx`, you may want to explore the `docker` and `docker compose` commands and the broader Docker “ecosystem”. Some people maintain elaborate development environments in Docker and install very little on their host workstation.

Of course, no harm should be done if you set things up locally and invoke Docker containers as a fallback. The remainder of this appendix is for those who want to set everything they need up on their work machine and any live instances (servers, CI/CD) directly.

<a id="other-cli-tools"></a>
#### Auxiliary tools and host-side installs

Some tools work best when installed directly on your host machine rather than inside the container. Having them available on your host can improve performance, integration with other software, and ease of use.

Similarly, tools that need to _affect_ your host environment outside a particular project directory, simply need to be installed on the host.

This guide advises installing the following tools directly on your host system, even if you leave others to DocOps Box containers.

<dl>
<dt>Git</dt>
<dd>
DocOps Box does its best alias a proper host installation, but it does better when there _is_ a proper host installation. Git is one of the easiest tools to “maintain” and one of the handiest to have installed directly on your host.
</dd>
<dt>Zsh</dt>
<dd>
MacOS users already enjoy Zsh as their default shell, and Linux users can easily install it with their package manager.
</dd>
<dt>VS Code integrations</dt>
<dd>
Language servers, linters, and formatters that VS Code invokes while you type (ESLint, Prettier, the Vale extension’s binary). Install these directly according to their own documentation so your editor can find them.
</dd>
<dt>Tools you call constantly from a terminal</dt>
<dd>
If you find yourself typing `dxbx ex asciidoctor …​` or `dxbx ex pandoc …​` dozens of times a day, it is probably time to install those tools on your host. **Pandoc** has minimal host-side dependencies and [installs cleanly](#native-pandoc) on MacOS, Linux, and WSL2 without a version manager.

**Asciidoctor** is better installed through a proper runtime platform, such as Ruby, Node.js, or JVM. This guide recommends [Ruby](#native-ruby) and [Node.js](#native-nodejs).

Creating an alias command in your host shell that invokes these tools via container `alias pandoc='dxbx ex pandoc'` can be a good middle ground if you don’t want to install them directly on your host but want to avoid typing `dxbx ex` every time. Frankly, `dxbx ex` is kept as simple as possible to make this less of an issue.
</dd>
</dl>

Having a tool installed both on the host and inside the container causes no conflict. The container’s <code class="term">PATH</code>[<sup>🔖</sup>](#gloss-path) is entirely separate; each invocation independently resolves to whichever install is in scope.

<a id="everything-native"></a>
#### Use Everything Natively

If you have decided it is worth the trouble to **install the software directly and locally** , this is your guide to minimizing overhead.

Advice on the few tough choices involved and some maintenance tips are included.

<a id="windows-dependencies"></a>
##### Windows Users

It is perfectly possible to run all of these programs and environments, and much more, under **WSL2** on Windows 10 or 11. This is strongly recommended as the way to maintain an optimal, consistent environment. Skip to the [Linux guide](#linux-dependencies) to get started.

---
<!-- block::sidebar -->
##### [SIDEBAR] Truly Native Windows Dev Environment

Alternatively, you can get all of this stuff to **run directly on Windows** , though I do not recommend that route.

It has become especially possible to run a proper development environment on Windows 10/11, particularly with the **GitBBash** program that ships with [Git for Windows](https://git-scm.com/download/win).

Ruby has a [Windows installer](https://rubyinstaller.org/downloads/) (choose the latest x64 with Devkit), and it’s supposedly even possible to install [Zsh on Windows](https://dev.to/equiman/zsh-on-windows-without-wsl-4ah9).

It is far from irrational to install everything on Windows, but it’s also probably not optimal, since WSL2 works so well and aligns your system with the absolute vast majority of professional and open-source coders (including anyone with a Mac).

Because this path is not recommended, this guide will not instruct it. However, the links above are a good place to start.

Otherwise, stick with WSL2, and skip to the [Linux guide](#linux-dependencies).
<!-- end::sidebar -->
---

<a id="macos-dependencies"></a>
##### MacOS Users

Mac users will likely have the fewest steps to get everything installed, especially if you already have Homebrew set up.

> **TIP:** [**Homebrew**](https://brew.sh) is an _essential_ resource on MacOS. It is the equivalent of an official package manager in Linux distributions, managing dependencies and easing the update process. It also keeps you out of Apple’s sphere of control when it comes to installing and maintaining CLI tools and even GUI apps like VS Code, Slack, Postman, LibreOffice, and more.

MacOS **ships with Zsh** , and you are probably already using it. I recommend further customizing with [OhMyZsh](https://ohmyz.sh/), but otherwise no action is needed.

Likewise, MacoS **ships with Git**. Try the command `git --version` to ensure that it is installed.

If not, Homebrew to the rescue!

```
brew install git
```

Even though OSX comes with **Ruby** pre-installed, it is _not properly set up for our purposes_, and you will likely see lots of errors and be forced to use the `sudo` command prefix to perform commands as superuser, which is not advised.

Instead, use rbenv or another [Ruby management platform](#native-ruby), as instructed below.

<a id="linux-dependencies"></a>
##### Linux Users (Including WSL)

Install any packages _except Ruby_ using your package manager.

For example, on Ubuntu- or Debian-based distributions, you can install Zsh and Git with:

```
sudo apt-get install zsh git
```

Your distribution likely does not come with Ruby installed, and we do not advise using your package manager to install it. This is likewise true for [Node.js](#native-nodejs).

Most Linux distributions ship with Python 3 installed. See the section in this guide on [Python](#native-python) for instructions on managing Python versions if needed.

<a id="native-ruby"></a>
#### Use a Ruby management system

Even if your operating system already has Ruby installed, you should reinstall with a version manager. This is **especially the case with MacOS** , which has weird permissions issues with its native installation.

My personal version manager of choice is [rbenv](https://github.com/rbenv/rbenv). I have never seen rbenv installation fail using their recommended procedure.

If you are feeling adventurous, rbenv’s maintainer keeps [this list of alternative Ruby managers](https://github.com/rbenv/rbenv/wiki/Comparison-of-version-managers), with good things to say about several of them. I may get around to experimenting with them, but for now my instructions will assume rbenv.

---
<!-- block::sidebar -->
##### [SIDEBAR] So, Which Ruby Version?

The default version in the accompanying Docker image is 3.3, which is well-supported across the gem ecosystem. The latest supported version (3.4) can also be used; choose it for new projects.

With rbenv or an equivalent version manager you can keep multiple versions on hand for projects with divergent dependencies. In that case, set different local versions:

```
rbenv install 3.3
rbenv install 3.4
rbenv global 3.4
cd project-a
rbenv local 3.3
cd ../project-b
rbenv local 3.4
```

All executions of `ruby`, `bundle exec`, etc. will use the locally appropriate Ruby stack. This approach is compatible with the DocOps Box/`dxbx` method, which uses the right Docker image per project.
<!-- end::sidebar -->
---

<a id="ruby-gems-global"></a>
#### Add Ruby gems globally

Once Ruby is installed, you can install any gems you like globally on your host system.

The ones that ship with DocOps Box `work` images are:

```
gem install asciidoctor kramdown-asciidoc nokogiri tilt
```

If you decide not to use the Docker image, you may still wish to use the optional software included in the image. Here we instruct setting up the other runtimes and utilities that are included in the DocOps Box Docker image.

<a id="native-nodejs"></a>
#### Node.js

Whether you use Node.js as a main runtime environment or not, you will sooner or later surely need the Node Version Manager (nvm) application to manage Javascript assets.

Both nvm and Node.js are best installed using their [platform- and installer-specific documentation](https://nodejs.org/en/download/package-manager). Be sure to choose your platform (Linux or MacOS). For the rest, leave default settings, unless you have reason to do otherwise.

> **NOTE:** Windows users should definitely install these resources on their WSL2 hosting instance, even though there are Windows versions available.

As of now, the Version 24 line is most widely used, including by the DocOps Box images.

If you need multiple versions of Node.js, that’s what nvm is for. Just use commands like <code class="prompt">nvm install 22</code> and <code class="prompt">nvm use 22</code> to switch between versions.

<a id="native-python"></a>
#### Python

Most Linux and MacOS distributions come with Python 3 pre-installed, including the Ubuntu and Fedora distributions that work with WSL2 on Windows.

In my experience, the pre-installed Python versions are usually sufficient for the tools we tend to use for docs-as-code. If you need to install or manage Python versions, the [pyenv](https://realpython.com/intro-to-pyenv/) tool is a good choice, with installation instructions for all platforms.

Similarly to Ruby on MacOS, the pre-installed Python on Linux may have permissions issues that make it difficult to work with.

<a id="native-pandoc"></a>
#### Pandoc

Even if Pandoc is not central to your documentation toolchain, sooner or later it will be just the right tool. It can be especially useful during one-time migrations from one source format to another.

> **NOTE:** It may be more sensible to install Pandoc directly on Windows in addition to WSL2, just for ease of access.

Pandoc maintains [downloads and installation instructions](https://pandoc.org/installing.html) for all operating systems.

<a id="native-vale-cli"></a>
#### Vale

Vale is a prose linter that can be configured with style guides to enforce writing standards.

Follow Vale’s [installation instructions](https://vale.sh/docs/install) for your platform to set it up natively.

<a id="native-libreoffice-cli"></a>
#### LibreOffice CLI

To take advantage of any of LibreOffice’s document manipulation tools or extensions, install the CLI tools.

Support for LibreOffice functionality on the command line comes in two separate tools: [`soffice`](https://www.systutorials.com/linux-manual-page-1-soffice/) and [`unoconv/unoserver`](https://github.com/unoconv/unoserver/).

Unfortunately, installation of these tools is complicated. Look to the DocOps Box `Dockerfile` for reference, but novice users may need help with this step. The `unoserver` command relies on Python, and the `soffice` command comes with LibreOffice utilities and may already be available or may need multi-step installation.

<a id="native-redocly-cli"></a>
#### Redocly CLI

Redocly CLI is a powerful tool for managing OpenAPI documents, including generating API references from them. It runs on your Node.js runtime, so you can install it with npm:

```
npm install -g @redocly/cli
```

<a id="other-customizations"></a>
#### Other environment customizations

The DocOps Box `work` images include a handful of quality-of-life tweaks beyond the default Zsh/OhMyZsh setup.

If you are running these tools on your host, you can reproduce any of these you find useful.

<dl>
<dt>Shell: command aliases</dt>
<dd>
Add to your `~/.zshrc` (or `~/.bashrc`):

```bash
alias edit=nano
alias ls="ls -lha --color=auto" 1
alias cat="bat --paging=never" 2
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias jekyllserve="bundle exec jekyll serve --host=0.0.0.0"
```

1. `ls` with human-readable sizes, hidden files shown, and colorized output.
2. `bat` is a syntax-highlighting wrapper for `cat`; [install natively](https://github.com/sharkdp/bat#installation)
</dd>
<dt>Shell: directory navigation</dt>
<dd>
Add to `~/.zshrc` to enable `cd`-free navigation and a pushd stack:

```bash
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
```
</dd>
<dt>Shell: case-insensitive tab completion</dt>
<dd>
Add to `~/.zshrc`:

```bash
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
```
</dd>
<dt>Git defaults</dt>
<dd>
Sane defaults for everyday workflows. Run:

```
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.autoSetupRemote true
git config --global core.pager cat
```
</dd>
<dt>nano settings</dt>
<dd>
Create or edit `~/.nanorc`:

```bash
set linenumbers
set mouse
set tabsize 2
set softwrap
```
</dd>
<dt>Vim settings</dt>
<dd>
Create or edit `~/.vimrc`:

```bash
syntax on
filetype plugin indent on
set number
```
</dd>
</dl>

<a id="background-context"></a>
### Appendix E: Background and Context

This project emerged from numerous attempts to provide robust runtime environments for clients with complex needs and insufficient capacity to learn or maintain all of these platforms.

Truth be told, many or even most developers cannot or wish they did not have to maintain complicated development environments on their local machines. This is especially true for technical writers and other documentation professionals, who tend to have less experience with and appreciation for command-line tools, package managers, and recursive dependency chains.

<a id="threading-needle"></a>
#### Threading the needle with Docker

Short of being a turn-key/magic-wand solution, DocOps Box is meant to be a one-stop-shop, or maybe a first-stop-shop, for getting “up and running” with what I think most people will need to perform powerful tasks with digital documents of various kinds.

There will inevitably be further installation and configuration steps to perform before you’re automating all your document operations. This project intends to get you to that point without much knowledge of Linux, Ruby, Node.js, Python, Git, SSH, or even Docker, for that matter.

The main purposes of technologies such as Docker, Compose, and Dev Containers are to facilitate ready-made environments that are consistent across teams and throughout software-production and -delivery pipelines. In this sense, they are _purpose built_ for some expert to design/configure them to fit a certain situation that may be useful to dozens or thousands of non-experts who just need to perform tasks in a reliable state.

I spent years watching my clients (mostly technical writers on Windows) struggle to get Ruby and its dependencies installed so they could work locally with the platforms I assembled for them.

Docker genuinely fulfils the promise of containerization, providing just-right environments that unify a team around standardized setups. But getting there on your own means choosing the right base image, wiring up volumes, user ID mapping, environment variables, SSH key handling, and a compose file that everyone can actually use.

All of that adds up fast. Without experience and context, even using LLMs (“AI”) to generate Dockerfiles and compose files can lead to very messy results that only compound when shared with a team.

And suddenly all the `docker build` and `docker run` commands you need to execute to get going are so complex that they are more of a barrier than the original problem of installing the environment on your host machine.

This is why DocOps Box includes configuration files and a `dxbx` executable. At least for getting your environment ready, commands should be extremely simple, with all the complexity of Docker and even Compose abstracted away.

<a id="alternatives"></a>
#### Why not the alternatives?

DocOps box attempts to expand this per-application approach to something like a per-domain approach, where the domain is “document operations” for multiple projects or distinct sets of documents. It does not promise to be “all things to all users”, but it does make some big promises. One is that this project is more convenient to new users than the alternatives.

To be certain, let’s explore those alternative means of “#bootstrapping”[<sup>🔖</sup>](#gloss-bootstrap) a document operations environment, and how we hope to ensure this project is a better way to get up and running.

<dl>
<dt>native installation instructions</dt>
<dd>
There are advantages to native installation of all the tools you need, but it is also the most time-consuming and maintenance-heavy approach. The `README` file instructs how to install and configure the necessary tools directly on each user’s host machine. This approach tends to require the most active maintenance, and of course it takes users the most time to set up.

See the [Installing Everything to Host](#ruby-for-real) section for instructions on installing Ruby for an example of how much documentation might be needed just for setup instructions for each project.
</dd>
<dt>virtual machines</dt>
<dd>
Setting up a virtual machine with tools like VirtualBox or Vagrant can provide an isolated environment, but it requires more resources, a steeper learning curve, and more maintenance than Docker containers. VMs are also not ideal for CI/CD pipelines, cloud-based development environments, or quick one-off tasks.
</dd>
<dt>Codespaces</dt>
<dd>
Cloud-hosted development environments like GitHub Codespaces can be configured with a `.devcontainer` directory in your repository. While Codespaces offers a seamless experience for users with GitHub accounts, it is not universally accessible, especially for those working in private repositories or without GitHub accounts.

Codespaces is also not a local environment, and honestly I just cannot advise working in a cloud system because I cannot fathom working that way myself. It is possible that cloud-first is a better way to learn docs-as-code tools and workflows, but I have not even heard this claim, and I would not be the person to lead such a project.
</dd>
</dl>

If anyone knows of other approaches that might be better for providing such a broad swath of technologies in a ready-to-use way, I would love to hear about it.

The `dxbx` script always shows you the exact Docker commands it runs, which has the handy side effect of teaching you the underlying tooling if you care to learn it. If you advance to the point where `docker compose` commands feel natural, you can use them directly; nothing about DocOps Box locks you in.

<a id="why-ruby"></a>
#### Why Ruby?

It is common to hear Ruby described as somewhat in decline as a programming language. Fortunately, its vast and well-maintained library of tools (typically packaged and published as “gems”) is still in widespread use, and the community is alive and well.

Ruby is the basis for countless excellent command-line tools and APIs, including [Asciidoctor](https://asciidoctor.org), [Liquid](https://shopify.github.io/liquid), [Jekyll](https://jekyllrb.com), [Nokogiri](https://nokogiri.org), and [Guard](https://github.com/guard/guard). Additional tools that are not Ruby-native but have excellent Ruby APIs include [Pandoc](https://pandoc.org) (via [pandoc-ruby](https://github.com/xwmx/pandoc-ruby)) and [ImageMagick](https://imagemagick.org/) (via [rmagick](https://github.com/rmagick/rmagick)).

I make no claim that Ruby is somehow the ultimate runtime environment for document automation. Node.js and Python are strong contenders, and a truly complex docs-management system may of necessity incorporate more than one runtime.

Nevertheless, the main thread of my software preferences is Ruby-native, and DocOps Box is directly aimed at getting people up and running with those tools.

The `max` images carry Node.js and Python alongside Ruby precisely so the environment does not become a dead end if your toolchain requires them. These images are suitable for and tested with numerous Node.js and Python tools.

<a id="why-zsh"></a>
#### Why Zsh?

Ever since Apple made Z shell the default shell on MacOS, I have felt confident recommending it to anyone needing a terminal shell. As a superset of Bash, Zsh users can always run Bash scripts and commands without conflict.

Zsh provides a noticeably better user experience out of the box, and [OhMyZsh](https://ohmyz.sh) builds on it with sensible defaults:

- <kbd class="key">Tab</kbd> autocompletes commands, filenames, and even CLI arguments.
- <kbd class="key">↑</kbd> / <kbd class="key">↓</kbd> cycles through your command history; <kbd class="keyseq"><kbd class="key">Ctrl</kbd>+<kbd class="key">R</kbd></kbd> searches it.
- Prompt syntax highlighting shows you whether a command is recognized before you press <kbd class="key">Enter</kbd>.

These features are technically achievable in Bash with enough plugins and configuration, but Zsh and OhMyZsh make them trivially available from day one. The only downside: you may miss them when stuck at a bare server Bash prompt, which is exactly why `live` images stay on Bash, where CI/CD environments expect it.

<a id="adr"></a>
#### Architecture Decision Rationale

<dl>
<dt>Why Docker + Compose?</dt>
<dd>
Raw `docker run` commands quickly grow unwieldy: volumes, ports, user IDs, environment variables, image tags, all of them manually specified each time. Docker Compose externalizes all of that into a versioned `docopsbox.yml`, making the run configuration reproducible and shareable in Git.

Fortunately, the breadth of DocOps use cases does not require a complex multi-service setup, so the Compose file is simple and approachable for users new to Docker.
</dd>
</dl>

<dl>
<dt>Why no Podman support?</dt>
<dd>
Podman is a promising alternative to Docker that I simply don’t have real experience with. So far my clients and colleagues have already had access to and often professional support for Docker. Adding Podman support seems like a worthy goal, but I have not investigated the complexity or the maintenance overhead it will add. See about [tool requests below](#tool-request) if you would like to see this added.
</dd>
</dl>

<dl>
<dt>Why separate `work` and `live` contexts?</dt>
<dd>
Interactive daily work benefits from things that automated pipelines do not, such as Z shell, TUI text editors, and full terminal tooling. Including these in a `live` CI/CD image wastes build time and inflates image size. Separate contexts keep each image lean and purpose-built.

That said, you could also use one `max:work` image for both purposes early on if you don’t wish to fuss about the distinction.
</dd>
</dl>

<dl>
<dt>Why named volumes for all dependency caches?</dt>
<dd>
Dependency trees for Ruby, Node.js, and Python all produce Linux-native artifacts (compiled gem extensions, Node binary modules, Python virtualenv symlinks) that are wrong-architecture or broken when accessed from the host filesystem on MacOS or Windows. Keeping them in named volumes (invisible to the host) removes that failure mode entirely and eliminates bind-mount overhead on MacOS. Keeping dependency files invisible to the host filesystem also keeps searches cleaner than if they were stashed in a directory under the project root.

Dependency caches are _disposable and fully reproducible_ `bundle install`, `npm install`, or `pip install` regenerates them in minutes.
</dd>
</dl>

<dl>
<dt>Why an entrypoint script?</dt>
<dd>
Docker images deployed to a registry cannot know the UID or GID of the user who will run them. Placing UID/GID reconciliation in the image’s own `ENTRYPOINT` script (rather than baking it at build time or requiring a separate file in the user’s project) satisfies all three requirements simultaneously: it runs on every `docker run` or `docker compose run` invocation, works with pre-built registry images, requires no extra files in the user’s project directory.

The entrypoint detects the `HOST_UID` and `HOST_GID` environment variables (passed in by `docopsbox.yml`), adjusts the container user’s identity to match, then drops privileges and executes the original command (`$CMD` or the default shell). On MacOS with Docker Desktop, the VM layer provides transparent ownership mapping and the entrypoint is a no-op (it does nothing and throws no error).
</dd>
</dl>

<dl>
<dt>Why no [your runtime here]?</dt>
<dd>
The `max` images include Ruby, Node.js, and Python because they are the environments I repeatedly find myself using and recommending to clients. Tempted as I am to add Java, Go, and Rust, I have no real experience supporting these platforms and only sporadic need. Go, Haskell, and Rust applications typically compile to static binaries that run just fine on the host, such as Vale and Pandoc. Adding more runtimes would also bloat the image size and build time, and I want to keep the project focused on documentation operations rather than becoming a general-purpose development environment.

_If you have a strong case for a runtime or tool_ not currently included that would likely be widely appreciated, [file a tool-request issue](https://github.com/DocOps/box/issues/new?labels=tool%20request). I will consider adding it if it fits the project’s scope and my experience, or at least I will document my reasons for declining and help you build a custom image with your tool included.
</dd>
</dl>

<!-- vale DocOpsLab-Authoring.Spelling = NO -->

<dl>
<dt>Should we vibe code it?</dt>
<dd>
Absolutely not. See [my blog post](https://docopslab.org/blog/vibe-coding-vs-programming/) as well as [“Most vibe-coded tools are not for you”](https://passo.uno/tools-slop-is-a-problem/) from fellow traveler Fabrizio Ferri Benedetti for approved takes on the quality bar for shippable software. LLM/agent assistance is welcome, but everything gets fully reviewed and manually pressure tested.
</dd>
</dl>

<!-- vale DocOpsLab-Authoring.Spelling = YES -->

<a id="development"></a>
### Appendix F: Development and Contribution

DocOps Box is maintained by [DocOps Lab](https://github.com/DocOps).[Contributions](#contributing) are welcome.

<a id="building-locally"></a>
#### Building Locally

1. Clone the repo.

2. Build a permutation of the image.

<a id="smoke-tests"></a>
#### Smoke Tests

For now, execute these sample commands to make sure your new image is working properly.

```
docker run --rm docopslab/box-mine:work ruby --version
docker run --rm docopslab/box-mine:work bundle --version
docker run --rm docopslab/box-mine:work git --version
docker run --rm docopslab/box-mine:work pandoc --version
docker run --rm docopslab/box-mine:work npm --version
docker run --rm docopslab/box-mine:work python3 --version
```

<a id="contributing"></a>
#### Contributing

See our [Contributors Guide](https://docopslab.org/docs/contributing/) for general policy and instructions.

Main ways to contribute:

1. [Open an issue](https://github.com/DocOps/box/issues) for bug reports or feature proposals.
2. Fork the repository and submit a pull request.

Contributions should:

- Not break the `min:live` CI/CD use case.
- Not increase `max` image size unnecessarily.
- Update this README alongside any user-facing changes.
- Follow the AsciiDoc authoring conventions used throughout this document.

