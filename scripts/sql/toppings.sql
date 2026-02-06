CREATE TABLE IF NOT EXISTS toppings (
    id                  VARCHAR(36)     PRIMARY KEY,    -- UUID
    name                VARCHAR(255)    NOT NULL,       -- name for package managers
    url                 VARCHAR(255)    NOT NULL,       -- official website, github repo, ...
    os                  VARCHAR(25)     NOT NULL,       -- $OS.linux, $OS.windows
    package_manager     VARCHAR(25)     NOT NULL,       -- package manager required for installation
    glaze_id            VARCHAR(36)     NOT NULL,       -- glaze reference ID
    FOREIGN KEY (glaze_id) REFERENCES glazes (id) ON UPDATE CASCADE ON DELETE CASCADE
)
