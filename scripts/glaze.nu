# Glaze support library

use ./config.nu [HOOK SCOPE LOWEST_PRIORITY]

# Builds the complete manifest for a glaze and returns it.
export def build-manifest [
    name: string                            # glaze unique name
    --category (-c): string = 'utility'     # glaze category
    --description (-d): string = ''         # glaze description
    --dependencies (-D): list<string> = []  # glaze dependencies
    --files (-f): list<string> = []         # glaze files
    --hook (-h): string = $HOOK.install     # glaze installation hook
    --priority (-p): int = $LOWEST_PRIORITY # glaze priority
    --toppings (-t): list<
        record<
            name: string
            url: string
            os: string
            package_manager: string>> = []  # glaze toppings
    --scope (-s): string = $SCOPE.common    # glaze scope
]: nothing -> record {
    let reviver = {|name, field|
        $toppings
        | where name == $name
        | first
        | get --optional $field
        | default ''
    }

    {
        name: $name
        category: $category
        dependencies: $dependencies
        description: $description
        files: $files
        hook: $hook
        toppings: ($toppings | str replace -r '^\{(.+)\.(.+)\}$' $reviver url)
        priority: $priority
        scope: $scope
    }
}
