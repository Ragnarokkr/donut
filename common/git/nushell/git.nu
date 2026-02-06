# Installs a pre-commit hook for gitleaks in current git repository.
def gitleaks-precommit [] {
    if not (".git" | path exists) {
        print -e $"(ansi red)Error: you're not into a git repository.(ansi reset)"
        return null
    }

    let home_dir = if "HOME" in $env { $env.HOME } else if "USERPROFILE" in $env { $env.USERPROFILE }
    let src = ([$home_dir .git-hooks pre-commit] | path join)
    let dst = ([.git hooks pre-commit] | path join)

    cp $src $dst

    if (which chmod | is-not-empty) { chmod +x $dst }
}
