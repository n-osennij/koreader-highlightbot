local http = require("socket.http")
local ltn12 = require("ltn12")
local helpers = require("lib.helpers")

local telegram_api = {}

function telegram_api.send_message(token, chat_id, message)
    local url = "https://api.telegram.org/bot" .. token .. "/sendMessage"
    local body = "chat_id=" .. helpers.urlencode(tostring(chat_id))
               .. "&parse_mode=HTML"
               .. "&disable_web_page_preview=1"
               .. "&text=" .. helpers.urlencode(message)

    local resp_chunks = {}
    local res, code, headers, status = http.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Content-Length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(resp_chunks),
    }

    local resp_body = table.concat(resp_chunks)
    
    -- Ошибки транспорта
    if not res then
        return false, string.format("HTTP error: %s", tostring(code))
    end
    
    -- HTTP-код не 200
    if tonumber(code) ~= 200 then
        return false, string.format("Failed (HTTP %s): %s", tostring(code), resp_body or "No body")
    end
    
    -- Telegram может вернуть 200 с ok=false
    if not resp_body:find('"ok"%s*:%s*true') then
        local desc = resp_body:match('"description"%s*:%s*"([^"]+)"')
        return false, string.format("Telegram error: %s", desc or resp_body)
    end
    
    return true
end

return telegram_api
