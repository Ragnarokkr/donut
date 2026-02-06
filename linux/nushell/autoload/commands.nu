def os-release [] {
  open /etc/os-release | parse "{key}={value}"
}

def "clean trash" [] {
    mut trash_path = ""
    if "XDG_DATA_HOME" in $env {
        $trash_path = [ $env.XDG_DATA_HOME Trash ] | path join
    } else {
        $trash_path = [ $env.HOME .local share Trash ] | path join
    }

    if ( $trash_path | path exists ) {
        rm --recursive --permanent ([ $trash_path files ] | path join )/*
        rm --recursive --permanent ([ $trash_path info ] | path join )/*
    }
}
