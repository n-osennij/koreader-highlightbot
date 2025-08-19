local util = require("util")
local _ = require("gettext")
local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")

local helpers = {}

function helpers.get_plugin_path()
    local info = debug.getinfo(2, "S")
    local src = info and info.source or ""
    src = src:gsub("^@", "") -- strip leading '@'
    return src:match("(.*/)") or ""
end

function helpers.trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function helpers.html_escape(s)
    if not s or s == "" then return "" end
    s = s:gsub("&", "&amp;")
         :gsub("<", "&lt;")
         :gsub(">", "&gt;")
         :gsub("\"", "&quot;")
         :gsub("'", "&#39;")
    return s
end

function helpers.urlencode(str)
    if not str then return "" end
    return (str:gsub("\n", "\r\n")
               :gsub("([^%w _%%%-%.~])", function(c) return string.format("%%%02X", string.byte(c)) end)
               :gsub(" ", "%%20"))
end

function helpers.is_online()
    local ok, res = pcall(function()
        return socket.dns.toip("api.telegram.org")
    end)
    return ok and res ~= nil
end

-- Форматирование даты на русском
local months_gen = {
    "января","февраля","марта","апреля","мая","июня",
    "июля","августа","сентября","октября","ноября","декабря"
}

function helpers.format_date_ru()
    local day = os.date("%d")
    local month_idx = tonumber(os.date("%m"))
    local year = os.date("%Y")
    local month_gen = months_gen[month_idx]
    return string.format("%s %s %s", day, month_gen, year)
end

function helpers.build_message(author, title, quote_text)
    local date_str = helpers.format_date_ru()

    local author_escaped = helpers.html_escape(author)
    local title_escaped = helpers.html_escape(title)
    local quote_escaped = helpers.html_escape(helpers.trim(quote_text or ""))

    local message = string.format([[
✍️ %s
📖 %s
🗓 %s

<blockquote>%s</blockquote>]], 
        author_escaped, 
        title_escaped, 
        date_str, 
        quote_escaped)

    return message
end

return helpers
