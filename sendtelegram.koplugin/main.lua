local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

-- Загрузка модулей
local helpers = require("lib/helpers")
local book_info = require("lib/book_info")
local telegram_api = require("lib/telegram_api")
local ui_extensions = require("lib/ui_extensions")
local telegram_actions = require("lib/telegram_actions")

-- Загрузка конфигурации
local config_loader = require("lib/config_loader")
local TOKEN, CHAT_ID = config_loader.load_config()

local SendTelegram = WidgetContainer:extend{
    name = "sendtelegram",
    is_doc_only = false,
}

function SendTelegram:init()
    self.helpers = helpers
    self.book_info = book_info
    self.telegram_api = telegram_api
    self.ui_extensions = ui_extensions
    self.telegram_actions = telegram_actions
    
    if self.ui and self.ui.highlight then
        self.ui_extensions.addToHighlightDialog(self)
    end
end

function SendTelegram:send_to_telegram(raw_text, selection_data)
    if not self.telegram_actions.check_prerequisites(self, raw_text) then
        return
    end

    self.telegram_actions.save_highlight(self, selection_data, raw_text)
    self.telegram_actions.send_message(self, raw_text, TOKEN, CHAT_ID)
end

function SendTelegram:onAnnotationContextMenu(menu, annotation)
    self.ui_extensions.onAnnotationContextMenu(self, menu, annotation)
end

return SendTelegram