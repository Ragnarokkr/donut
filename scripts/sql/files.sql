CREATE TABLE IF NOT EXISTS files (
    id          VARCHAR(36)     PRIMARY KEY,    -- UUID
    filepath    VARCHAR(255)    NOT NULL,       -- absolute file path
    glaze_id    VARCHAR(36)     NOT NULL,       -- glaze reference ID
    FOREIGN KEY (glaze_id) REFERENCES glazes (id) ON UPDATE CASCADE ON DELETE CASCADE
)
