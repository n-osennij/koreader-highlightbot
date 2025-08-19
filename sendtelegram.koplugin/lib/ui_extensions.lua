local InfoMessage = require("ui/widget/infomessage")
local util = require("util")
local _ = require("gettext")

local ui_extensions = {}

function ui_extensions.addToHighlightDialog(self)
    self.ui.highlight:addToHighlightDialog("12_send_to_telegram", function(this)
        return {
            text = _("Send to Telegram"),
            callback = function()
                if this.selected_text and this.selected_text.text then
                    local cleaned = util.cleanupSelectedText(this.selected_text.text)
                    self:send_to_telegram(cleaned, this.selected_text)
                end
                this:onClose()
            end,
        }
    end)
end

function ui_extensions.onAnnotationContextMenu(self, menu, annotation)
    if annotation and annotation.text then
        menu:addItem{
            text = _("Send to Telegram"),
            callback = function()
                self:send_to_telegram(annotation.text, nil)
            end,
        }
    end
end

return ui_extensions