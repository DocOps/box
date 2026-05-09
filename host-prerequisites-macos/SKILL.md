---
name: host-prerequisites-macos
description: Guide to installing and configuring the prerequisites for using DocOps
  Box on macOS, including Bash 4, Docker Desktop, and VS Code.
tables-to-markdown: 'true'
---

# MacOS Host Prerequisites Guidance
DocOps Box offers official guidance for installing and configuring the prerequisites on all major platforms. This guide covers the specific steps for macOS users, including installing Docker Desktop, Visual Studio Code, and the `dxbx` CLI.

<a id="prereq-terminal"></a>
## Terminal App (All OSes; Advised)

There is no avoiding the command line in the docs-as-code world. If you already have a terminal you like, use it and skip ahead.

> **TIP:** It is **strongly advised** that you choose a terminal app _other than the one in VS Code_, simply for differentiation of duties, at least when getting started. Use VS Code’s terminal inside the containerized environment; use an external terminal for `dxbx` commands and other host-level work.

If you are unaware of or unhappy with your terminal app, here are my recommendations per operating system.

<a id="warp-wave-terminal"></a>
### Warp and Wave

By far my two favorite terminal apps are Warp and Wave. Both are free, open-source programs with optional AI integration, at a cost.

> **WARNING:** Both Wave and Warp install with telemetry be enabled by default, and it is required for free AI use. Paid users can opt out of telemetry, as can free users not wishing to partake of the AI features.

Warp has a fully AI-integrated terminal that can be a little bit overwhelming but provides excellent interactivity between terminal and GUI[<sup>🔖</sup>](#gloss-gui).

Wave’s AI aspect is chat-only for now, so you have to copy and paste commands and output back and forth, though the chat can automatically read local files.

Both are excellent terminal emulators _aside from or despite_ the optional AI tie-in.

- [Download Warp](https://www.warp.dev/terminal) (downloads for all platforms in page footer)
- [Download Wave](https://www.waveterm.dev/download)
- **MacOS users** can use the built-in Terminal app, but most users prefer [iTerm2](https://iterm2.com/downloads.html), which is also available as a Homebrew package:

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
> - Windows users can skip to [[prereq-wsl2]](#prereq-wsl2).

<a id="prereq-bash4"></a>
## Bash 4+ (MacOS Only)

The [quick-start](#quickstart) procedure will ensure you have Bash 4 or higher on your host. For legal reasons, MacOS comes with Bash 3, but it is highly advised and **100% harmless** to add Bash 4+ to your system.

> **NOTE:** Adding Bash 4 does not replace Z Shell as your default system/interactive shell.

The bootstrap script will offer to install Bash 4+ via Homebrew (as well as Homebrew itself) if not already present.

Like all prerequisites, Bash 4 is an essential tool for working with developer tools and workflows.

> **TIP:** Mac users can skip to [Docker (All OSes)](#prereq-docker).

<a id="prereq-docker"></a>
## Docker (All OSes)

Docker is a platform that allows you to run a _containerized Linux environment_ on your system. Containers are much lighter and more customizable than full virtual machines. They are specifically designed for creating consistent environments for development and automation.

See [[threading-needle]](#threading-needle), [[adr]](#adr), and _most usefully_ the [Docker glossary section](#glossary-docker) for more context. This section covers the nuts and bolts of installation.

<a id="docker-macos"></a>
### Docker on MacOS

The preferred method is the [Docker Desktop installer](https://docs.docker.com/desktop/install/mac-install/).

Alternatively, use [Homebrew](https://brew.sh). Follow [these instructions](https://www.delftstack.com/howto/docker/brew-docker/) to install Homebrew if needed as well as full instructions for installing and starting Docker.

