local ui_utils = require("lib/ui_utils")
local _ = require("gettext")

local telegram_actions = {}

function telegram_actions.check_prerequisites(self, raw_text)
    if not self.ui or not self.ui.document then
        ui_utils.show_info(_("Документ не загружен."), "notice-warning")
        return false
    end

    if not raw_text or raw_text == "" then
        ui_utils.show_info(_("Текст не выделен."), "notice-warning")
        return false
    end

    return true
end

function telegram_actions.save_highlight(self, selection_data, raw_text)
    if not self.ui or not selection_data or not self.ui.highlight or not self.ui.highlight.saveHighlight then
        return
    end

    local current_page = self.ui.document:getCurrentPage()
    if not current_page then
        return
    end

    local highlight = {
        selection = selection_data,
        text = raw_text,
        type = "highlight",
        style = "highlight",
        datetime = os.time(),
        page = current_page,
    }

    pcall(function()
        self.ui.highlight:saveHighlight(highlight)
    end)
end

function telegram_actions.send_message(self, raw_text, token, chat_id)
    if not self.helpers.is_online() then
        ui_utils.show_info(_("ОШИБКА! Цитата НЕ ОТПРАВЛЕНА! Включите Wi-Fi и проверьте подключение к интернету."), "notice-warning")
        return false
    end

    local book = self.book_info.get_book_info(self)
    local message = self.helpers.build_message(book.author, book.title, raw_text)

    local ok, err = pcall(function()
        local success, err_msg = self.telegram_api.send_message(token, chat_id, message)
        if not success then
            error(err_msg)
        end
    end)

    if ok then
        ui_utils.show_info(_("Успешно отправлено в Telegram!"), "notice-info", 2)
    else
        ui_utils.show_info(tostring(err), "notice-error", 5)
    end

    return ok
end

return telegram_actions