CREATE TABLE IF NOT EXISTS session (
    state         VARCHAR(32) NOT NULL DEFAULT('{state}'),                      -- $STATE.*
    last_session  DATETIME    NOT NULL DEFAULT(DATETIME('NOW', 'LOCALTIME'))    -- last time the script was executed
)
