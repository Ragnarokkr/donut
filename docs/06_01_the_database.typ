=== The Database <the-database>

The system utilizes an SQLite database to track glazes, toppings, and
environmental state.

```txt
Performs operations on the database

Usage:
  > donut db {flags}

Flags:
  -h, --help: Display the help message for this command
  -c, --security-clean: Cleans sensitive environment settings from database
  -u, --update: Initializes/Updates the database
```

The `--security-clean` flag prevents sensitive data, like API keys, from leaking
if cached in the database during sync.

Use the `--update` flag whenever a glaze is added, updated, deleted, or when
related files are modified.
