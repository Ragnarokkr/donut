CREATE TABLE IF NOT EXISTS dependencies (
    id              VARCHAR(36) PRIMARY KEY,    -- UUID
    dependency_id   VARCHAR(36) NOT NULL,       -- dependency glaze reference ID
    glaze_id        VARCHAR(36) NOT NULL,       -- glaze reference ID
    FOREIGN KEY (dependency_id) REFERENCES glazes (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (glaze_id)      REFERENCES glazes (id) ON UPDATE CASCADE ON DELETE CASCADE
)
