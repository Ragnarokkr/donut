mkdir ($nu.user-autoload-dirs | first)
zoxide init nushell
  | save -f ([($nu.user-autoload-dirs | first) zoxide.nu] | path join)
