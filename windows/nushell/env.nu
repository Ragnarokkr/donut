load-env {
    PATH: ($env.PATH | prepend ([$env.SystemDrive UserApp] | path join))
    EDITOR: (
        if      (which helix        | is-not-empty) { "helix" }
        else if (which hx           | is-not-empty) { "hx" }
        else if (which fresh        | is-not-empty) { "fresh" }
        else if (which msedit       | is-not-empty) { "msedit" }
        else ""
    )
    VISUAL: (
        if      (which zed          | is-not-empty) { "zed" }
        else if (which code         | is-not-empty) { "code" }
        else if (which code-insider | is-not-empty) { "code-insider" }
        else if (which notepad      | is-not-empty) { "notepad" }
        else $env.EDITOR
    )
}
