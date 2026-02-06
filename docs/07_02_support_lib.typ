=== Scripts and Support Library <scripts-and-support-library>

Under the hood, `donut` is powered by a collection of specialized scripts
and libraries stored in `scripts/` and `scripts/libs/`.

#table(
  columns: (auto, auto),
  table.header([*Script*], [*Description*]),

  `scripts/config.nu`, [provides application-wide configuration data],
  `scripts/database.nu`, [provides utility commands to interact with the application database],
  `scripts/glaze.nu`, [provides utility commands to work with the glazes],
  `scripts/messages.nu`, [provides application-wide messages],
  `scripts/libs/archive.nu`, [provides utility commands to work with compressed archives],
  `scripts/libs/fs.nu`, [provides utility commands to work with the file-system],
  `scripts/libs/log.nu`, [provides a rudimentary logging system for the application],
  `scripts/libs/net.nu`, [provides utility commands to access the network],
  `scripts/libs/strings.nu`, [provides utility commands to work with strings],
  `scripts/libs/system.nu`, [provides utility commands to interact with the host system],
)
