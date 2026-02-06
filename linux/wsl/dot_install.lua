local config = require("config")
local log = require("log")
local lfs = require("lfs")

-- Fix WSL issue as described in https://github.com/microsoft/wslg/issues/1032

-- Check if inside a WSL environment
local handle = io.open("/proc/version", "r")
if not handle then
    log.error("Failed to open /proc/version")
    return false
end
local version = handle:read("*all")
handle:close()
if not version:find("microsoft") and not version:find("WSL2") then return end

local src = config.paths.work .. "/wsl"
local dest = config.paths.config_home .. "/systemd/user"

if not lfs.attributes(dest .. "wsl-wayland-symlink.service", "mode") == "file" then
    log.action("Configuring WSL")
    if not os.execute("mkdir -p " .. dest) then return false end
    log.action("Symlinking", "wsl-wayland-symlink.service", dest)
    lfs.link(src .. "/wsl-wayland-symlink.service", dest .. "/wsl-wayland-symlink.service", true)
    log.action("Enabling", "wsl-wayland-symlink.service")
    if not os.execute("systemctl --user daemon-reload") then return false end
    if not os.execute("systemctl --user enable wsl-wayland-symlink.service") then return false end
    if not os.execute("systemctl --user start wsl-wayland-symlink.service") then return false end
end

return true
