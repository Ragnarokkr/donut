$env.config.show_banner = false
$env.config.history.max_size = 10000
$env.config.rm.always_trash = true
$env.config.buffer_editor = $env.EDITOR
$env.config.filesize.precision = 3

# Plugins
const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
 ...$NU_PLUGIN_DIRS
]
