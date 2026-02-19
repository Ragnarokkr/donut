mkdir ($nu.user-autoload-dirs | first)
nudo completion
  | save -f ([($nu.user-autoload-dirs | first) nudo.nu] | path join)
