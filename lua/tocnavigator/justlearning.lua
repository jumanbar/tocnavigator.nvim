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
local bufnr = find_buffer_by_name('/home/juan/Nvim/tocnavigator.nvim/lua/tocnavigator/tests/test.md')
-- local bufnr = vim.api.nvim_get_current_buf()
print('test.md', bufnr)
print('test.md name', vim.api.nvim_buf_get_name(bufnr))

local defaults = {
    after = "normal zt",
    r = {
        toc_comments = true,
        cmslen = 1,
        functions = true,
    },
    markdown = {
        title = true
    },
    lua = {
        toc_comments = true,
        cmslen = 0,
        functions = true,
    },
    javascript = {
        toc_comments = true,
        cmslen = 2,
        functions = true,
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
    }
}

local function foo()
    print("QSYO")
end

--- Otro punto
local ft = vim.filetype.match({ buf = bufnr })
print("FileType:", ft)

local ltree = vim.treesitter.get_parser(bufnr, ft)
local stree = ltree:parse()
local root = stree[1]:root()



-- QUERIES -----

local queries = q[ft]
local cpt = ""
local txt = ""
local node_type = ""
-- print(vim.inspect(queries))
local out = {}
for i, query in pairs(queries) do
    local qparsed = vim.treesitter.query.parse(ft, query)
    -- print("i", i, "-------", vim.inspect(qparsed))
    for id, node, _ in qparsed:iter_captures(root, bufnr, 0, -1) do
        cpt = qparsed.captures[id]
        -- print(cpt)
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
    for i in pairs(t) do
        if t[i].node_type == "paragraph" then
            for j in pairs(t) do
                if t[j].line == t[i].line + 1 and string.match(t[j].node_type, "1") then
                    -- t[i].text = "" .. t[i].text
                    t[j] = nil
                    break
                end
                if t[j].line == t[i].line + 1 and string.match(t[j].node_type, "2") then
                    t[i].text = "  " .. t[i].text
                    t[j] = nil
                    break
                end
            end
        else
            prefix = string.gsub(string.match(t[i].text, "(#+)"), "#", "  ")
            suffix = string.match(t[i].text, "^#+%s*(.*)")
            t[i].text = string.sub(prefix .. suffix, 3)
        end
    end

    return t
end

if ft == "markdown" then
    out = processMD(out)
end

print("------------")
--print(vim.inspect(out))

for i in pairs(out) do print(out[i].text) end


