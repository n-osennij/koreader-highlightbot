local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local InfoMessage = require("ui/widget/infomessage")
local util = require("util")
local _ = require("gettext")
local socket = require("socket.http")

-- Get the plugin's directory path
local function get_plugin_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

-- Load config from the same directory
local plugin_path = get_plugin_path() or ""
local config = dofile(plugin_path .. "config.lua")
local TOKEN = config.telegram.token
local CHAT_ID = config.telegram.chat_id

local SendTelegram = WidgetContainer:extend{
    name = "sendtelegram",
    is_doc_only = false,
}

function SendTelegram:init()
    if self.ui.highlight then
        self:addToHighlightDialog()
    end
end

local function urlencode(str)
    if not str then return "" end
    return (str:gsub("\n", "\r\n")
              :gsub("([^%w _%%%-%.~])", function(c) return string.format("%%%02X", string.byte(c)) end)
              :gsub(" ", "%%20"))
end

local function get_book_info(self)
    local info = {
        title = "Unknown",
        page = "?",
        total_pages = "?",
        file_name = "Unknown"
    }
    
    if self.ui and self.ui.document then
        if self.ui.document.info and self.ui.document.info.title then
            info.title = self.ui.document.info.title
        end
        
        if self.ui.document.file then
            info.file_name = self.ui.document.file:match("([^/]+)$") or self.ui.document.file
            if not info.title or info.title == "" or info.title == "Unknown" then
                info.title = info.file_name
            end
        end
        
        if self.ui.document.getPageCount then
            info.total_pages = self.ui.document:getPageCount()
        end
        if self.ui.document.getCurrentPage then
            info.page = self.ui.document:getCurrentPage()
        end
    end
    
    return info
end

function SendTelegram:send_to_telegram(text)
    local book_info = get_book_info(self)
    
    local message = string.format([[
📖 %s
📄 Page %s of %s
⏰ %s

%s]], 
        book_info.title,
        book_info.page,
        book_info.total_pages,
        os.date("%Y-%m-%d %H:%M"),
        text
    )

    local url = string.format(
        "https://api.telegram.org/bot%s/sendMessage?chat_id=%s&text=%s",
        TOKEN,
        CHAT_ID,
        urlencode(message)
    )

    local ok, response = pcall(function()
        local body, response_code, headers, status = socket.request(url)
        return {
            code = response_code,
            body = body,
            status = status,
            headers = headers
        }
    end)

    local error_message
    if not ok then
        error_message = string.format("Error: %s", tostring(response))
    elseif response.code ~= 200 then
        error_message = string.format("Failed (HTTP %d): %s", response.code, response.body or "No response body")
    end

    UIManager:show(InfoMessage:new{
        text = error_message and error_message or _("Sent to Telegram!"),
        duration = error_message and 5 or 2,  -- Show errors longer
    })
end

function SendTelegram:addToHighlightDialog()
    self.ui.highlight:addToHighlightDialog("12_send_to_telegram", function(this)
        return {
            text = _("Send to Telegram"),
            callback = function()
                if this.selected_text and this.selected_text.text then
                    self:send_to_telegram(util.cleanupSelectedText(this.selected_text.text))
                end
                this:onClose()
            end,
        }
    end)
end

-- Handle annotations
function SendTelegram:onAnnotationContextMenu(menu, annotation)
    if annotation and annotation.text then
        menu:addItem{
            text = _("Send to Telegram"),
            callback = function()
                self:send_to_telegram(annotation.text)
            end,
        }
    end
end

return SendTelegram