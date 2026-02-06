local config = require("config")
local log = require("log")
local lfs = require("lfs")
require("xstring")

local src = config.paths.work .. "/zsh"
local dest = config.paths.home

if not lfs.attributes("/var/cache/zsh", "mode") == "directory" then
    log.action("Creating", "/var/cache/zsh")
    if not os.execute(string.format("%s mkdir -p /var/cache/zsh", config.sudo)) then
        log.error("Failed to create /var/cache/zsh")
        return false
    end
end

if not lfs.attributes("/etc/pacman.d/hooks", "mode") == "directory" then
    log.action("Creating", "/etc/pacman.d/hooks")
    if not os.execute(string.format("%s mkdir -p /etc/pacman.d/hooks", config.sudo)) then
        log.error("Failed to create /etc/pacman.d/hooks")
        return false
    end

    log.action("Copying", "zsh.hook", "/etc/pacman.d/hooks/")
    if not os.execute(string.format("%s cp %s/zsh.hook /etc/pacman.d/hooks/", config.sudo, src)) then
        log.error("Failed to copy zsh.hook")
        return false
    end
end

for entry in lfs.dir(src) do
    if entry == "." or entry == ".." then goto continue end
    if entry:startswith("[.]") then
        log.action("Symlinking", entry)
        if not lfs.link(src .. "/" .. entry, dest .. "/" .. entry, true) then
            log.error("Failed to symlink " .. entry)
            return false
        end
    end
    ::continue::
end

dest = config.paths.config_home .. "/zsh"
log.action("Symlinking", src .. "/functions", dest .. "/functions")
if lfs.attributes(dest .. "/functions", "mode") == "directory" then lfs.rmdir(dest .. "/functions") end
if not lfs.link(src .. "/functions", dest .. "/functions", true) then
    log.error("Failed to symlink functions")
    return false
end
