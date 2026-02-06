=== Directory Structure <directory-structure>

```
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
```
To ensure compatibility with the automation logic, please maintain the default
directory structure. Of course, if you're a rebel who needs a custom layout,
you can redefine the paths in #link("scripts/config.nu")[scripts/config.nu].

You have full creative freedom over the contents of the glaze's directory under
`common/`, `linux/`, and `windows/` directories. That said, following the
convention of placing Nushell files (`commands.nu`, `aliases.nu`, `env.nu`, etc.)
inside a dedicated `nushell/` subdirectory will make your Glazes much easier
to manage.

The `docs/` directory contains the Typst source used to generate this
documentation. To produce the GFM Markdown version, use
#link("https://pandoc.org/")[Pandoc]:

```sh
pandoc -f typst -t gfm -o README.md docs/README.typ
```

The `scripts/` directory houses the core logic and support libraries required
by `donut` and individual glazes. It also includes the `sql/` folder, which
contains the schemas used to build the application's database.

The `glazes/` folder hosts only the scripts of the registered glazes.
