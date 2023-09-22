-- Comentario doc ======
local q = require("lua.tocnavigator.queries")
-- local x = vim.cmd [[BufReadCmd lua/tocnavigator/tests/test.md]]

--[[
    Source:
    https://github.com/nvim-neo-tree/neo-tree.nvim/blob/e968cda658089b56ee1eaa1772a2a0e50113b902/lua/neo-tree/utils.lua#L157-L165
]]
local find_buffer_by_name = function(name)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(buf)
        print(buf_name)
        if buf_name == name then
            print('este')
            return buf
        end
    end
    return -1
end
local bufnr = find_buffer_by_name('/home/juan/Nvim/tocnavigator.nvim/lua/tocnavigator/tests/test.sh')
-- local bufnr = vim.api.nvim_get_current_buf()
print('test', bufnr)
print('test name', vim.api.nvim_buf_get_name(bufnr))

local defaults = {
    bash = {
        toc_comments = true,
        cmslen = 1,
        functions = true,
    },
    javascript = {
        toc_comments = true,
        cmslen = 2,
        functions = true,
    },
    lua = {
        toc_comments = true,
        cmslen = 0,
        functions = true,
    },
    markdown = {
        title = true
    },
    php = {
        toc_comments = true,
        cmslen = 2,
        functions = true,
    },
    python = {
        toc_comments = true,
        cmslen = 1,
        functions = true,
    },
    r = {
        toc_comments = true,
        cmslen = 1,
        functions = true,
    },
}

local function foo()
    print("QSYO")
end

--- Otro punto
local ft = vim.filetype.match({ buf = bufnr })
if ft == "sh" then ft = "bash" end
print("FileType:", ft)

local ltree = vim.treesitter.get_parser(bufnr, ft)
local stree = ltree:parse()
local root = stree[1]:root()

-- print(vim.inspect(ltree))

-- QUERIES -----
local queries = q[ft]
local txt = ""
local node_type = ""
local out = {}
for i, query in pairs(queries) do
    local qparsed = vim.treesitter.query.parse(ft, query)
    -- print("i", i, "-------", vim.inspect(qparsed))
    for id, node, _ in qparsed:iter_captures(root, bufnr, 0, -1) do
        txt = vim.treesitter.get_node_text(node, bufnr)
        node_type = node:type()
        -- print(node:type())
        if i == "toc_comments" then
            txt = string.sub(txt, defaults[ft].cmslen + 1)
        end
        local row1, _, row2, _ = node:range()
        -- Verify that it is not a block comment
        if (i == "toc_comments" and row1 == row2) or i ~= "toc_comments" then
            table.insert(out, { type = i, node_type = node_type, line = row1 + 1, text = vim.trim(txt) })
        end
    end
end

table.sort(out, function(a, b)
    return a.line < b.line
end)

local function processMD(t)
    local prefix = ""
    local suffix = ""
    local prefix_match = ""
    local bullet = ""
    for i in pairs(t) do
        if t[i].node_type == "paragraph" then
            for j in pairs(t) do
                if t[j].line == t[i].line + 1 and string.match(t[j].node_type, "1") then
                    -- t[i].text = "" .. t[i].text
                    t[i].text = "\u{2981} " .. t[i].text
                    t[j] = nil
                    -- Unicode U+2981 -- SOLID
                    break
                end
                if t[j].line == t[i].line + 1 and string.match(t[j].node_type, "2") then
                    t[i].text = "  " .. "\u{25E6} " .. t[i].text
                    t[j] = nil
                    break
                end
            end
        else
            prefix_match = string.match(t[i].text, "(#+)")
            if prefix_match == "#" then
                bullet = "\u{2981} "
                -- Unicode U+2981 -- SOLID
            else
                bullet = "\u{25E6} "
                -- Unicode U+25E6 -- VOID
            end
            prefix = string.gsub(prefix_match, "#", "  ")
            suffix = string.match(t[i].text, "^#+%s*(.*)")
            t[i].text = string.sub(prefix .. bullet .. suffix, 3)
        end
    end

    return t
end

local function process_hash(t)

    local prefix = ""
    local suffix = ""
    local prefix_match = ""
    local bullet = ""
    for i in pairs(t) do
        if t[i].node_type == "comment" then
            prefix_match = string.match(t[i].text, "(#+)") or ""

            if prefix_match == "" then
                bullet = "\u{2981} "
                -- Unicode U+2981 -- SOLID
            else
                bullet = "\u{25E6} "
                -- Unicode U+25E6 -- VOID
            end

            prefix = string.gsub(prefix_match, "#", "  ")
            suffix = string.match(t[i].text, "^#*%s*(.*)") or ""
            suffix = string.gsub(suffix, "%s*[-=]+%s*$", "")
            t[i].text = string.sub(prefix .. bullet .. vim.trim(suffix), 1)
        else
            t[i].text = prefix .. " \u{1D191} " .. t[i].text
            -- Unicode U+1D191
        end

    end
end

local function process_dslash(t)
    local prefix = ""
    local suffix = ""
    local prefix_match = ""
    local bullet = ""
    local text = ""
    for i in pairs(t) do
        if t[i].node_type == "comment" then
            text = string.gsub(t[i].text, "(%/+%s*)", "", 1)

            prefix_match = string.match(t[i].text, "(#+)") or ""

            if prefix_match == "" then
                bullet = "\u{2981} "
                -- Unicode U+2981 -- SOLID
            else
                bullet = "\u{25E6} "
                -- Unicode U+25E6 -- VOID
            end

            prefix = string.gsub(prefix_match, "#", "  ")
            suffix = string.match(text, "^#*%s*(.*)") or ""
            suffix = string.gsub(suffix, "%s*[-=]+%s*$", "")
            t[i].text = string.sub(prefix .. bullet .. vim.trim(suffix), 1)
        else
            t[i].text = prefix .. " \u{1D191} " .. t[i].text
            -- Unicode U+1D191
        end
    end
end


-- print(vim.inspect(out))
if ft == "markdown" then
    out = processMD(out)
end
if ft == "r" or ft == "python" or ft == "bash" then
    process_hash(out)
end
if ft == "javascript" or ft == "php" then
    process_dslash(out)
end


print("------------")

-- print(vim.inspect(out))
print("------------")
for i in pairs(out) do print(out[i].text) end


