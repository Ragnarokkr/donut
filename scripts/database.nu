use config.nu [HOOK STATE SCOPE DATETIME_RESET SQL_DIR DATABASE_PATH GLAZES_DIR LOWEST_PRIORITY]
use messages.nu *
use libs/log.nu *
use libs/strings.nu *
use libs/system.nu [is-linux is-windows]

# Gets the absolute path to the database
export def db-path []: nothing -> path {
    if (is-linux) {
        if 'XDG_DATA_HOME' in $env {
            [$env.XDG_DATA_HOME donut] | path join $DATABASE_PATH
        } else {
            [$env.HOME .local share donut] | path join $DATABASE_PATH
        }
    } else if (is-windows) {
        if 'LOCALAPPDATA' in $env {
            [$env.APPDATA donut] | path join $DATABASE_PATH
        } else {
            [$env.USERPROFILE] | path join $DATABASE_PATH
        }
    }
}

# Formats the date for current database
export def format-db-date []: datetime -> string {
    $in | format date '%F %T'
}

# Executes SQL statements with or without transaction
export def execute-sql [
    sql_statement: string               # SQL statement
    --params (-p): oneof<list, record>  # list of parameters for the SQL statement
    --transaction (-t)                  # executes SQL statement with transaction
] {
    try {
        if $transaction { stor open | query db 'BEGIN TRANSACTION' }
        let result = stor open | query db $sql_statement -p $params
        if $transaction { stor open | query db 'COMMIT' }
        $result
    } catch {
        if $transaction { stor open | query db 'ROLLBACK' } else { [] }
    }
}

# Loads the database
export def load-db []: nothing -> table {
    stor import -f (db-path)
}

# Saves the new database
export def save-db []: nothing -> table {
    let db_path: path = db-path
    if ($db_path | path exists) {
        rm -fp $db_path
    }
    mkdir ($db_path | path dirname)
    stor export -f $db_path
}

# Initializes application database
export def init-db [] {
    stor reset | query db (open ($SQL_DIR | path join session.sql) | template { state: $STATE.initial })
    stor open | query db (open ($SQL_DIR | path join environment.sql) | template { hook: $HOOK.install priority: $LOWEST_PRIORITY })
    stor open | query db (open ($SQL_DIR | path join glazes.sql) | template { scope: $SCOPE.common hook: $HOOK.install priority: $LOWEST_PRIORITY })
    stor open | query db 'CREATE INDEX glazes_index ON glazes (hook, priority, name, scope)'
    stor open | query db (open ($SQL_DIR | path join files.sql))
    stor open | query db (open ($SQL_DIR | path join toppings.sql))
    stor open | query db (open ($SQL_DIR | path join dependencies.sql))
}

# Initializes session data
export def init-session []: nothing -> table {
    if (execute-sql 'SELECT COUNT(*) FROM session' | transpose -d).column1? == 0 {
        execute-sql -t 'INSERT INTO session (state, last_session) VALUES (?, ?)' -p [$STATE.initial (date now | format-db-date)]
    } else {
        execute-sql -t 'UPDATE session SET last_session = ?' -p [(date now | format-db-date)]
    }

    save-db
}

# Initializes/Updates the application database.
export def update-db [] {
    mut stats = { added: 0 updated: 0 removed: 0 }
    let is_updating = db-path | path exists

    # Searches all available glazes (*.nu scripts)
    log -s database $MESSAGE.db_info_searching
    let glazes = glob -D ($GLAZES_DIR | path join '*.nu') | where {|path| nu-check $path }
    log -s database ($MESSAGE.db_info_found | template { total: ($glazes | length) })

    if $is_updating {
        # Loads the existing database
        log -s database ($MESSAGE.db_info_status | template { status: 'Loading' })
        load-db
    } else {
        # Initializes a new empty database
        log -s database ($MESSAGE.db_info_status | template { status: 'Initializing' })
        init-db
    }

    init-session

    log -s database ($MESSAGE.glaze_info_generic
    | template { status: (if $is_updating { 'Updating' } else { 'Registering' }) })

    for g in $glazes {
        let manifest = nu $g manifest | from json
        mut glaze_id: string = ''

        if not $manifest.success {
            log -l $LOG_LEVEL.warning ($MESSAGE.glaze_err_manifest | template { glaze: $g })
            continue
        }

        # Adds or updates glaze's manifest data
        if $is_updating {
            let row = execute-sql 'SELECT id, name FROM glazes WHERE name = ? LIMIT 1' -p [$manifest.data.name]
            if ($row | is-not-empty) {
                $glaze_id = $row.0.id
                update-glaze $glaze_id $manifest.data
                $stats.updated += 1
            } else {
                $glaze_id = add-glaze $manifest.data
                $stats.added += 1
            }
        } else {
            $glaze_id = add-glaze $manifest.data
        }

        # Removes old files and stores the new ones
        if $is_updating {
            execute-sql -t 'DELETE FROM files WHERE glaze_id = ?' -p [$glaze_id]
        }

        for p in [$g ...$manifest.data.files] {
            for f in (glob -D $p) {
                add-file $glaze_id $f
            }
        }

        # Removes old toppings and adds the new ones
        if $is_updating {
            execute-sql -t 'DELETE FROM toppings WHERE glaze_id = ?' -p [$glaze_id]
        }

        for t in $manifest.data.toppings {
            add-topping $glaze_id $t
        }
    }

    log -s database ($MESSAGE.glaze_info_dep_generic
    | template { status: (if $is_updating { 'Updating' } else { 'Resolving' }) })

    for g in $glazes {
        let manifest = nu $g manifest | from json

        if not $manifest.success {
            log -l $LOG_LEVEL.warning ($MESSAGE.glaze_err_manifest | template { glaze: $g })
            continue
        }

        let data = $manifest.data
        let glaze_id = execute-sql 'SELECT id FROM glazes WHERE name = ? LIMIT 1' -p [$data.name] | first | get -o id

        # Removes old dependencies and adds the new ones
        if $is_updating {
            execute-sql -t 'DELETE FROM dependencies WHERE glaze_id = ?' -p [$glaze_id]
        }

        for d in $data.dependencies {
            let dependency_id = execute-sql 'SELECT id FROM glazes WHERE name = ? LIMIT 1' -p [$d] | first | get -o id

            if ($dependency_id | is-empty) {
                log -l $LOG_LEVEL.warning -s database ($MESSAGE.db_err_dependency | template { glaze: $d })
                continue
            }

            add-dependency $glaze_id $dependency_id
        }
    }

    if $is_updating {
        log -s database ($MESSAGE.db_info_status | template { status: 'Cleaning' })
        let stored_glazes = execute-sql 'SELECT id, name FROM glazes'
        for g in $stored_glazes {
            if ($glazes | find -i $"($g.name).nu" | is-empty) {
                execute-sql -t 'DELETE FROM glazes WHERE id = ?' -p [$g.id]
                $stats.removed += 1
            }
        }
    }

    log -s database ($MESSAGE.db_info_status | template { status: 'Saving'} )
    save-db

    if $is_updating {
        log -s database ($MESSAGE.db_info_stats | template $stats)
    }
}

# Adds a new glaze into the database
export def add-glaze [
    data: record # glaze manifest data
]: nothing -> string {
    let uuid = random uuid
    stor insert -t glazes -d {
        id: $uuid
        name: $data.name
        category: $data.category
        description: $data.description
        scope: $data.scope
        hook: $data.hook
        priority: $data.priority
        installed: $DATETIME_RESET
        configured: $DATETIME_RESET
    }
    $uuid
}

# Updates an existing glaze into the database
export def update-glaze [
    id: string # glaze id
    data: record # glaze manifest data
]: nothing -> nothing {
    stor update -t glazes -w $"id = '($id)'" -u {
        name: $data.name
        category: $data.category
        description: $data.description
        scope: $data.scope
        hook: $data.hook
        priority: $data.priority
    } | ignore
}

# Adds a new file into the database
export def add-file [
    id: string # glaze id
    filepath: path # file path
]: nothing -> string {
    let uuid = random uuid
    stor insert -t files -d {
        id: $uuid
        filepath: $filepath
        glaze_id: $id
    }
    $uuid
}

# Adds a new topping into the database
export def add-topping [
    id: string # glaze id
    data: record # topping's data
]: nothing -> string {
    let uuid = random uuid
    stor insert -t toppings -d {
        id: $uuid
        name: $data.name
        url: $data.url
        os: $data.os
        package_manager: $data.package_manager
        glaze_id: $id
    }
    $uuid
}

# Adds a new dependency into the database
export def add-dependency [
    id: string # glaze's id
    data: string # dependency's id
]: nothing -> string {
    let uuid = random uuid
    stor insert -t dependencies -d {
        id: $uuid
        dependency_id: $data
        glaze_id: $id
    }
    $uuid
}

# Adds environment changes to the queue.
export def add-environment [
    name: string                            # glaze's unique name
    body: string                            # glaze's settings to store
    --hook (-h): string = $HOOK.install     # $HOOK.preinstall, $HOOK.install
    --priority (-p): int = $LOWEST_PRIORITY # glaze's priority
]: nothing -> bool {
    # This command is mostly called from child processes (nu <script>) so it has
    # to reimport the database before executing the SQL statement.
    load-db
    let glaze_id = execute-sql 'SELECT id FROM glazes WHERE name = ? LIMIT 1' -p [$name] | get 0.id
    stor insert -t environment -d {
        id: (random uuid)
        body: $body
        hook: $hook
        priority: $priority
        glaze_id: $glaze_id
    }
    save-db
    $env.LAST_EXIT_CODE == 0
}

# Cleans out the environment table from changed glazes
export def reset-environment []: nothing -> nothing {
    let changed = execute-sql 'SELECT id FROM glazes WHERE installed = ? OR configured = ?' -p [$DATETIME_RESET $DATETIME_RESET]
    for $g in $changed {
        execute-sql -t 'DELETE FROM environment WHERE glaze_id = ?' -p [$g.id]
    }
    save-db | ignore
}
