# DoNuT (Dotfiles-Nushell Tracker)

<div align="center"><img src="docs/images/banner.webp"></div>

DoNuT is a personal experiment in building a lightweight dotfiles manager
using **Nushell**. It’s my custom kitchen for managing app installations and
syncing configuration files across different machines.

While I built this primarily for my own workflow, I’ve documented it here so
anyone else (including future-me) can follow the recipe without getting burned.

## Table of Contents

{TOC}

## Why another dotfiles manager?

Why build a new "tricky" manager when powerhouses like [Ansible], [Chezmoi],
[Dotter], [Stow] or [YADM] already exist?

Simple: **Because we can**. As programmers, we have an innate desire to
reinvent the wheel just to see how the rubber meets the road. Plus, I wanted a
system that feels native to Nushell—fast, structured, and fun to play with.

So, let’s start baking! 🍩

[ansible]: https://github.com/ansible/ansible "Ansible"
[chezmoi]: https://github.com/twpayne/chezmoi "Chezmoi"
[dotter]: https://github.com/SuperCuber/dotter "Dotter"
[stow]: https://www.gnu.org/software/stow/ "GNU Stow"
[yadm]: https://github.com/yadm-dev/yadm "Yet Another Dotfiles Manager"

## Getting Started

DoNuT is optimized for a dual-environment workflow: **Windows** (🤢) and
**ArchLinux** (specifically via **WSL**). Since **Nushell** is my primary
shell on both, the whole system is built to speak its language.

### Requirements

Before you start the oven, make sure you have:

- [Nushell]: Must be set as your default shell.
- [Git]: To clone the repo and track changes.
- **Linux specific**: [sudo] or [doas] for system-level tasks.
- **Windows specific**: [WSL] with [ArchLinux].

> [!TIP]
> If you are the only user on your Linux system, you can quickly set up
> permissions (**this must be done as root**):
>
> ```sh
> # For sudo
> echo "your_user_name ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/your_user_name > /dev/null
>
> # For doas
> echo "permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} your_user_name" | tee -a /etc/doas.conf > /dev/null
> ```

[archlinux]: https://archlinux.org/download/ "ArchLinux"
[doas]: https://github.com/Duncaen/OpenDoas "OpenDoas"
[git]: https://git-scm.com/install/ "Git"
[nushell]: https://www.nushell.sh/book/installation.html "Nushell"
[sudo]: https://www.sudo.ws/ "sudo"
[wsl]: https://learn.microsoft.com/en-us/windows/wsl/install "Windows Subsystem for Linux"

### Installation

Clone the repo and start the engine:

```sh
git clone https://github.com/Ragnarokkr/donut.git
cd donut
./donut  # On Windows, this runs donut.bat
```

> [!NOTE]
> On Linux, if the script doesn't run, try `nu ./donut` or `chmod u+x ./donut`.

### The Baking Process (Setup Workflow)

The setup is split into **two distinct phases**. Think of it like prepping
the dough vs. adding the glaze.

- **Phase 1**: Pre-heat (Preparation)
    - **Check**: Verifies you have the right tools installed.
    - **Pre-install**: Grabs essential helpers (like `paru` or `unzip`).
    - **Pre-config**: Sets up initial settings for those helpers.
    - **Restart**: A quick break to make sure the OS recognizes new tools.
- **Phase 2**: The Glaze (Installation)
    - **Install**: Downloads and installs your main apps.
    - **Config**: Sprinkles your personalized configuration files into the right places.
    - **Final Bake**: One last restart to ensure everything is stable and ready to serve.

## Terminology

This system uses **donuts** as a central metaphor. Why donuts? Well, who
doesn’t love donuts! I mean, even many famous Blender 3D artists started
with the well known [donut
tutorial](https://www.youtube.com/playlist?list=PLjEaoINr3zgGUwGwXlj9kBe7TrVWNjkyv)!

- **Glaze**: The _recipe_ (a Nushell script). It tells DoNuT how to install
  and configure a specific tool.
- **Topping**: The actual program or file. A Glaze generally includes one
  topping per custom installation or configuration. When no specific setup
  is required, multiple toppings can be logically grouped (e.g.,
  a "cli-tools" glaze might contain several command-line programs).

## Using the Script

The [donut](donut) command is your main tool. It's designed to be intuitive,
using Nushell's powerful table-based output.

    Usage:
    > donut

    Subcommands:
    donut db (custom) - Performs operations on the database
    donut glaze (custom) - Performs operations on glazes
    donut show (custom) - Show information about database or glazes

### The Database (db)

DoNuT uses a small SQLite database to keep track of what is installed.

- `db --update`: Run this if you manually add or change a Glaze script.
- `db --security-clean`: Wipes sensitive environment data (like API keys)
  from the DB.

### Managing Glazes (glaze)

Glazes are the building blocks of your system.

- `glaze --add`: Creates a new template for a tool you want to manage.
- `glaze --delete`: Removes a Glaze and its configuration files. **Be careful**!
- `glaze --reset`: Marks a Glaze as "not installed" so you can run its setup again.
  If no glaze is specified, all glazes will be marked.

> [!TIP]
> All glaze are generated from [scripts/glaze.tmpl.nu](scripts/glaze.tmpl.nu).

### Inspection (show)

Nushell shines here. You can view your setup in beautifully formatted tables.

- `show --info`: Shows the ingredients of a specific glaze. If you don’t
  specify one, it will serve up a menu of every registered glaze so you can
  pick your favorite to inspect.

    ```sh
    > ./donut show --info age
    ╭──────────────┬──────────────────────────────────────────────────────────────────────────────────────────╮
    │ name         │ age                                                                                      │
    │ category     │ security                                                                                 │
    │              │ ╭───┬───────────╮                                                                        │
    │ dependencies │ │ 0 │ bitwarden │                                                                        │
    │              │ ╰───┴───────────╯                                                                        │
    │ description  │ A simple, secure, and modern encryption tool.                                            │
    │ hook         │ install                                                                                  │
    │              │ ╭───┬─────────────────┬────────────────────────────────────┬─────────┬─────────────────╮ │
    │ toppings     │ │ # │      name       │                url                 │   os    │ package_manager │ │
    │              │ ├───┼─────────────────┼────────────────────────────────────┼─────────┼─────────────────┤ │
    │              │ │ 0 │ age             │ https://github.com/FiloSottile/age │ linux   │ pacman          │ │
    │              │ │ 1 │ FiloSottile.age │ https://github.com/FiloSottile/age │ windows │ winget          │ │
    │              │ ╰───┴─────────────────┴────────────────────────────────────┴─────────┴─────────────────╯ │
    │ priority     │ 1                                                                                        │
    │ scope        │ common                                                                                   │
    ╰──────────────┴──────────────────────────────────────────────────────────────────────────────────────────╯
    ```

    > [!TIP]
    > Since each glaze is just a Nushell script, you can directly see its data by
    > typing `nu glazes/<glaze_name>.nu --info`.

- `show --list`: Serves up a full menu of every glaze currently registered in
  the DoNuT database.

    ```sh
    > ./donut show --list
    ╭────┬──────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    │  # │       name       │                                                          description                                                          │
    ├────┼──────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
    │  1 │ age              │ A simple, secure, and modern encryption tool.                                                                                 │
    │  2 │ archivers        │ Various high performant archivers.                                                                                            │
    :    :                  :                                                                                                                               :
    │ 49 │ zellij           │ A terminal multiplexer.                                                                                                       │
    │ 50 │ zoxide           │ A smarter cd command. Supports all major shells.                                                                              │
    ├────┼──────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
    │  # │       name       │                                                          description                                                          │
    ╰────┴──────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
    ```

- `show --stats`: Shows the _nutrition facts_ of your setup. It serves up the
  overall totals for your glazes and toppings.

    ```sh
    ./donut show --stats
    ╭───────────────────────┬──────────────────────╮
    │ Registered Glazes     │ 52                   │
    │ Registered Categories │ 10                   │
    │ Tracked Files         │ 132                  │
    │ Environment Settings  │ 13                   │
    │ Common Scoped         │ 22                   │
    │ Linux Scoped          │ 18                   │
    │ Windows Scoped        │ 10                   │
    │ Disabled              │ 2                    │
    │ Last Session          │ 2 days ago           │
    │ DB Path               │ /..../donut/donut.db │
    ╰───────────────────────┴──────────────────────╯
    ```

## Technical Details

This section dives into the _kitchen_ of DoNuT. While the system is designed
to be easy to use, understanding the underlying architecture will help you
customize it without breaking the recipe.

### Directory Structure and Scoping

To ensure compatibility with the automation logic, DoNuT follows a
strict "Scope-Based" hierarchy. The script looks at your OS and pulls the
relevant ingredients automatically.

> [!TIP]
> Of course, if you’re a rebel who needs a custom layout, you can redefine
> the paths in [scripts/config.nu](scripts/config.nu).

    .
    ├── common              # configuration files common to all systems
    │   ├── age
    │   │   └── nushell
    │   ├── bitwarden
    │   │   └── nushell
    :   :
    ├── docs                # README documentation sources
    ├── glazes              # installation/configuration glazes
    ├── linux               # configuration files for Linux environment
    │   ├── btop
    │   ├── bun
    │   │   └── nushell
    :   :
    ├── scripts             # support scripts
    └── windows             # configuration files for Windows environment
        ├── cursors
        ├── nushell
        │   └── autoload
        ├── oh-my-posh
        │   └── nushell
    :   :

You have full creative freedom over the contents of the glaze’s directory
under `common/`, `linux/`, and `windows/` directories. That said, following
the convention of placing Nushell files (`commands.nu`, `aliases.nu`, `env.nu`,
etc.) inside a dedicated `nushell/` subdirectory will make your Glazes much
easier to manage.

- `common/`: The _base dough._ Anything here is linked regardless of whether
  you are on Windows or Linux (e.g., generic Neovim configs or Git ignore
  global).
- `linux/` & `windows/`: These are environment-specific _frostings._ Files
  here are only applied for the specific OS.
- `glazes/`: This is the restricted zone. Only `.nu` scripts live here. Each
  script must be named uniquely because DoNuT uses the filename as the identifier
  for every operation.
- `scripts/` directory houses the core logic and support libraries
  required by `donut` and individual glazes. It also includes the `sql/`
  folder, which contains the schemas used to build the application’s
  database.
- `docs/` directory contains the source used to generate this
  documentation. To produce the final document, use: `nu ./docs/generate.nu`

### Scripts and Support Library

Under the hood, `donut` is powered by a collection of specialized
scripts and libraries stored in `scripts/` and `scripts/libs/`.

| **Script**                | **Description**                                                     |
| ------------------------- | ------------------------------------------------------------------- |
| `scripts/config.nu`       | provides application-wide configuration data                        |
| `scripts/database.nu`     | provides utility commands to interact with the application database |
| `scripts/glaze.nu`        | provides utility commands to work with the glazes                   |
| `scripts/messages.nu`     | provides application-wide messages                                  |
| `scripts/libs/archive.nu` | provides utility commands to work with compressed archives          |
| `scripts/libs/fs.nu`      | provides utility commands to work with the file-system              |
| `scripts/libs/log.nu`     | provides a rudimentary logging system for the application           |
| `scripts/libs/net.nu`     | provides utility commands to access the network                     |
| `scripts/libs/strings.nu` | provides utility commands to work with strings                      |
| `scripts/libs/system.nu`  | provides utility commands to interact with the host system          |

### The Anatomy of a Glaze

#### The Manifest

A **Glaze** is a standard Nushell script, but it must export a specific record
(the "Manifest") so the main engine knows what to do with it. When you run
`donut show --info`, it's actually reading this record:

```sh
# Example of manifest returned by a glaze
def get-manifest []: nothing -> record {
    let common_dir: directory = work-dir $ID | get $SCOPE.common

    (build-manifest
        $ID
        --category 'security'
        --description 'A simple, secure, and modern encryption tool.'
        --priority $HIGHEST_PRIORITY
        --toppings [
            { name: 'age' url: 'https://github.com/FiloSottile/age' os: $OS.linux package_manager: 'pacman' }
            { name: 'FiloSottile.age' url: '{age.url}' os: $OS.windows package_manager: 'winget' }
        ]
        --dependencies ['bitwarden']
        --files [$"($common_dir | path normalize)/**/*"]
    )
}
```

By defining everything as a **Nushell Record**, we can filter, sort, and query
our dotfiles using standard tables—no more parsing messy text files with
`sed` or `awk`.

#### The `do-install` command (Custom Baking)

By default, DoNuT uses the toppings list in the manifest to install things
via the specified package manager. However, sometimes a program isn't in a
repository.

The `do-install` command is an optional hook used for "bespoke" installations.
If you need to download a specific binary from GitHub, compile something from
source, or run a custom installer, you put that logic here.

```sh
def do-install []: nothing -> bool {
    # YOUR LOGIC GOES HERE
}
```

#### The `do-config` command (The Finishing Touch)

This is where the actual configuration happens. After the software is
installed, DoNuT calls `do-config`. This command typically handles:

- **Symlinking**: Connecting the files in your scoped directories to the
  system's actual config paths (like `~/.config/`).
- **Environment Setup**: Setting specific variables that only this tool needs.
- **Cleanup**: Removing temporary files left over from the installation.

```sh
def do-config []: nothing -> bool {
    # YOUR LOGIC GOES HERE
}
```

#### Return Values

To keep the engine running smoothly, both `do-install` and `do-config` must
return a boolean value: `true` if the operation was a success, or `false` if
something went wrong during the bake. This allows DoNuT to halt the process
before a small error turns into a kitchen fire.

### The SQLite Engine

Most dotfile managers rely on the file system itself to track state.
DoNuT is different; it uses an **SQLite database** (`donut.db`) to manage the
"Lifecycle" of your configurations.

| Table          | Purpose                                                                                   |
| -------------- | ----------------------------------------------------------------------------------------- |
| `dependencies` | Tracks all the glazes a single glaze depends on.                                          |
| `environment`  | Caches environmental variables to put in the `env.nu` file.                               |
| `files`        | Tracks all the files a glazes provides.                                                   |
| `glazes`       | Stores the manifest data, installation status, and last-updated timestamp.                |
| `session`      | Stores all the internal states for a session.                                             |
| `toppings`     | Maps specific packages to their respective package managers (winget, pacman, paru, etc.). |

**Why SQLite**? It allows us to perform complex checks—like
"_Show me all Linux-scoped glazes that haven't been updated in 30 days_"—with
a single Nushell command: `db query "SELECT ..."`.

### The Template System

When you run `donut glaze --add <name>`, the system uses
[scripts/glaze.tmpl.nu](scripts/glaze.tmpl.nu). This template is pre-filled
with boilerplate code, ensuring that every new glaze you create is compatible
with the database schema and the main execution engine.

## TODOs

- [ ] **Clean** Command: Automate the removal of configuration files from the system.
- [ ] **Sync** Command: Push local changes back to the repository easily.
