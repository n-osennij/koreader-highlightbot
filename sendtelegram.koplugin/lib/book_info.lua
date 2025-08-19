local book_info = {}

function book_info.get_author(doc)
    if not doc then return "Unknown" end

    -- 1. Пытаемся получить структурированные метаданные через getProps()
    local props = doc:getProps()
    if props then
        if props.authors then
            if type(props.authors) == "table" then
                return table.concat(props.authors, ", ")
            elseif type(props.authors) == "string" and props.authors ~= "" then
                return props.authors
            end
        end
        if props.author and props.author ~= "" then
            return props.author
        end
        if props.creator and props.creator ~= "" then
            return props.creator
        end
    end

    -- 2. Резерв: doc.info (старый способ)
    local info = doc.info
    if info then
        if info.authors then
            if type(info.authors) == "table" then
                return table.concat(info.authors, ", ")
            elseif type(info.authors) == "string" and info.authors ~= "" then
                return info.authors
            end
        end
        if info.author and info.author ~= "" then
            return info.author
        end
        if info.creator and info.creator ~= "" then
            return info.creator
        end
        if info.metadata then
            if info.metadata["dc:creator"] then
                return info.metadata["dc:creator"]
            elseif info.metadata["author"] then
                return info.metadata["author"]
            end
        end
    end

    return "Unknown"
end

function book_info.get_book_info(self)
    local info = {
        title = "Unknown",
        author = "Unknown",
        page = "?",
        total_pages = "?",
        file_name = "Unknown",
    }

    local doc = self.ui and self.ui.document
    if not doc then return info end

    -- Название
    if doc.info then
        if doc.info.title and doc.info.title ~= "" then
            info.title = doc.info.title
        end
    end

    -- Файл
    if doc.file then
        local filename_with_ext = doc.file:match("([^/]+)$") or doc.file
        local filename_no_ext = filename_with_ext:match("(.+)%..+$") or filename_with_ext
        info.file_name = filename_no_ext
        if not info.title or info.title == "" or info.title == "Unknown" then
            info.title = info.file_name
        end
    end

    -- Автор(ы)
    info.author = book_info.get_author(doc)

    -- Страницы
    if doc.getPageCount then
        local ok, total = pcall(function() return doc:getPageCount() end)
        if ok and total then info.total_pages = total end
    end
    if doc.getCurrentPage then
        local ok, page = pcall(function() return doc:getCurrentPage() end)
        if ok and page then info.page = page end
    end

    return info
end

return book_info
