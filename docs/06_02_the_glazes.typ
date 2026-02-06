=== The Glazes <the-glazes>

Glazes serve as building blocks. To avoid repetition, the script automates
their creation and management.

```sh
Usage:
  > donut glaze {flags} (glaze)

Flags:
  -h, --help: Display the help message for this command
  -a, --add: Adds a new glaze module
  -d, --delete: Deletes an existing glaze module and its associated directories
  -r, --reset: Resets one or all glazes to their initial state

Parameters:
  glaze <string>: Glaze's unique name (optional)
```

The `--add` flag creates a new glaze in the `glazes/` directory. Additional
files must be manually created in a directory matching the glaze's name, located
within the relevant scope directory (`common`, `linux`, or `windows`).

#block(
  [[!TIP]
    All glaze files are generated from #link("scripts/glaze.tmpl.nu")[scripts/glaze.tmpl.nu].]
)

The `--delete` flag removes an existing glaze and its related directories from
the file system.

#block(
  [[!WARNING]
    All glaze files will be deleted. Ensure backups are made if needed!]
)

The `--reset` flag restores a registered glaze to its initial state for
re-execution.

#block(
  [[!NOTE]
    If no glaze name is provided, all glazes will be reset.]
)
