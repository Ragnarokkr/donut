CREATE TABLE IF NOT EXISTS environment (
    id          VARCHAR(36) NOT NULL,                       -- UUID
    body        TEXT        NOT NULL,                       -- content to store in env.nu
    hook        VARCHAR(15) NOT NULL DEFAULT('{hook}'),       -- $HOOK.preinstall, $HOOK.install
    priority    INT         NOT NULL DEFAULT({priority}),   -- $HIGHEST_PRIORITY..$LOWEST_PRIORITY
    glaze_id    VARCHAR(36) NOT NULL,                       -- glaze reference ID
    FOREIGN KEY (glaze_id) REFERENCES glazes (id) ON UPDATE CASCADE ON DELETE CASCADE
)
