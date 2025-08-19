local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local _ = require("gettext")

local ui_utils = {}

function ui_utils.show_info(text, icon, duration)
    UIManager:show(InfoMessage:new{
        text = text,
        icon = icon or "notice-info",
        duration = duration or 3,
    })
end

return ui_utils