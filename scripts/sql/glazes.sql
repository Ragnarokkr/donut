CREATE TABLE IF NOT EXISTS glazes (
    id          VARCHAR(36)     PRIMARY KEY,                            -- UUID
    name        VARCHAR(255)    NOT NULL,                               -- glaze unique name
    category    VARCHAR(255)    NOT NULL,                               -- glaze cateogory
    description VARCHAR(255),                                           -- glaze description
    scope       VARCHAR(25)     NOT NULL DEFAULT('{scope}'),              -- $SCOPE.common, $SCOPE.linux, $SCOPE.windows
    hook        VARCHAR(15)     NOT NULL DEFAULT('{hook}'),               -- $HOOK.preinstall, $HOOK.install
    priority    INT             NOT NULL DEFAULT({priority}),           -- $HIGHEST_PRIORITY..$LOWEST_PRIORITY
    installed   DATETIME        NOT NULL DEFAULT(DATETIME('1-1-1900')), -- last installation date
    configured  DATETIME        NOT NULL DEFAULT(DATETIME('1-1-1900'))  -- last installation date
)
