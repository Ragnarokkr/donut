$env.config.show_banner = false
$env.config.rm.always_trash = true
$env.config.buffer_editor = $env.EDITOR
$env.config.completions.algorithm = "fuzzy"
$env.config.error_style = "nested"
$env.config.table.trim = { methodology: "truncating", truncating_suffix: "..." }
$env.config.table.missing_value_symbol = ""
$env.config.datetime_format.table = "%F %T %a"
$env.config.datetime_format.normal = $env.config.datetime_format.table
$env.config.filesize.precision = 3

# Plugins
const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
 ...$NU_PLUGIN_DIRS
]

nudo tasks list
