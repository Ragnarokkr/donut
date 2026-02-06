load-env {
    PATH: ($env.PATH | prepend ~/.local/bin)
    EDITOR: (
        if      (which helix        | is-not-empty) { "helix" }
        else if (which hx           | is-not-empty) { "hx" }
        else if (which fresh        | is-not-empty) { "fresh" }
        else if (which nvim         | is-not-empty) { "nvim" }
        else if (which vim          | is-not-empty) { "vim" }
        else if (which vi           | is-not-empty) { "vi" }
        else if (which nano         | is-not-empty) { "nano" }
        else if (which msedit       | is-not-empty) { "msedit" }
        else if (which edit         | is-not-empty) { "edit" }
        else ""
    )
    VISUAL: (
        if      (which zed          | is-not-empty) { "zed" }
        else if (which code         | is-not-empty) { "code" }
        else if (which code-insider | is-not-empty) { "code-insider" }
        else $env.EDITOR
    )
}
