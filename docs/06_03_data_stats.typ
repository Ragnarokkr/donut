=== Data and Statistics <data-and-statistics>

View dotfile collection statistics.

```sh
Show information about database or glazes

Usage:
  > setup.nu show {flags} (glaze)

Flags:
  -h, --help: Display the help message for this command
  -i, --info: Shows information about a glaze
  -l, --list: Shows a list of all registered glazes
  -s, --stats: Shows database's overall statistics

Parameters:
  glaze <string>: glaze's unique name (optional)
```

The `--info` flag lets you peek at the ingredients of a specific glaze.
If you don't specify one, we'll serve up a menu of every registered glaze
so you can pick your favorite to inspect.

```sh
> ./setup.nu show --info age
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

The `--list` flag serves up a full menu of every glaze currently registered in
the DoNuT database.

```sh
> ./setup.nu show --list
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

If you want to see the _nutrition facts_ of your setup, the `--stats` flag
serves up the overall totals for your glazes and toppings.

```sh
./setup.nu show --stats
╭───────────────────────┬──────────────╮
│ Last Session          │ 18 hours ago │
│ Registered Glazes     │ 50           │
│ Registered Categories │ 10           │
│ Tracked Files         │ 125          │
│ Environment Settings  │ 12           │
│ Common Scoped         │ 21           │
│ Linux Scoped          │ 17           │
│ Windows Scoped        │ 10           │
│ Disabled              │ 2            │
╰───────────────────────┴──────────────╯
```
