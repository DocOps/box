---
name: host-prerequisites-windows
description: Guide to installing and configuring the prerequisites for using DocOps
  Box on Windows, including WSL2, Docker Desktop, and VS Code.
tables-to-markdown: 'true'
---

# Windows Host Prerequisites Guidance
DocOps Box offers official guidance for installing and configuring the prerequisites on all major platforms. This guide covers the specific steps for macOS users, including installing Docker Desktop, Visual Studio Code, and the `dxbx` CLI.

<a id="prereq-terminal"></a>
## Terminal App (All OSes; Advised)

There is no avoiding the command line in the docs-as-code world. If you already have a terminal you like, use it and skip ahead.

> **TIP:** It is **strongly advised** that you choose a terminal app _other than the one in VS Code_, simply for differentiation of duties, at least when getting started. Use VS Code’s terminal inside the containerized environment; use an external terminal for `dxbx` commands and other host-level work.

If you are unaware of or unhappy with your terminal app, here are my recommendations per operating system.

<a id="warp-terminal"></a>
### Warp and Wave

By far my two favorite terminal apps are Warp and Wave.

Both are freemium open-source models with generous free tiers.

Warp has a fully integrated terminal that can be a little bit overwhelming.

Wave is a chat-only tool for now, so you have to copy and paste commands and output back and forth, though the chat can automatically read local files.

- [Download Warp](https://www.warp.dev/terminal) (downloads for all platforms in page footer)
- [Download Wave](https://www.waveterm.dev/download)
- **Windows users** can use the built-in Windows Terminal, which supports multiple shells including PowerShell and WSL2. If it’s not installed, get it from the Microsoft Store: [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701).

<a id="prereq-vscode"></a>
## VS Code (All OSes; Advised)

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

<a id="prereq-wsl2"></a>
## WSL2 (Windows Only)
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
## Curl (All Hosts; Required)

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
## Docker (All OSes)

Docker is a platform that allows you to run a _containerized Linux environment_ on your system. Containers are much lighter and more customizable than full virtual machines. They are specifically designed for creating consistent environments for development and automation.

See [[threading-needle]](#threading-needle), [[adr]](#adr), and _most usefully_ the [Docker glossary section](#glossary-docker) for more context. This section covers the nuts and bolts of installation.

<a id="docker-wsl2"></a>
### Docker on Windows (WSL2)

Microsoft maintains [documentation for setting up Docker with WSL2](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers#install-docker-desktop).

> **TIP:** Follow that guide, then move on to [[quickstart]](#quickstart).

