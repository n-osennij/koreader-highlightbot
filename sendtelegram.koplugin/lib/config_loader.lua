local helpers = require("lib/helpers")
local _ = require("gettext")

local config_loader = {}

function config_loader.load_config()
    local plugin_path = helpers.get_plugin_path()
    local config = dofile(plugin_path .. "../config.lua")
    local TOKEN = assert(config and config.telegram and config.telegram.token, _("Missing telegram.token in config.lua"))
    local CHAT_ID = assert(config and config.telegram and config.telegram.chat_id, _("Missing telegram.chat_id in config.lua"))
    return TOKEN, CHAT_ID
end

return config_loader