load-env {
    PATH: ($env.PATH | prepend ($env.HOME | path join '/.bun/bin'))
}
