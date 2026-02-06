# https://github.com/Schniz/fnm/issues/463#issuecomment-3022203794

if (which fnm | is-not-empty) {
  ^fnm env --json | from json | load-env

  $env.PATH = $env.PATH | prepend ($env.FNM_MULTISHELL_PATH | path join (if $nu.os-info.name == 'windows' { '' } else { 'bin' }))
  $env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD? | append {
        condition: {|| ['.nvmrc' '.node-version', 'package.json'] | any {|el| $el | path exists }}
        code: {|| ^fnm use --install-if-missing}
    }
  )
}
