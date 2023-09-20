-- Comentario doc ======
local q = require("lua.tocnavigator.queries")

-- local x = vim.cmd [[BufReadCmd lua/tocnavigator/tests/test.md]]
local f = io.popen("lua/tocnavigator/tests/test.md", "r")
local s = f:read("*a")

print(vim.inspect(x))
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
local bufnr = vim.api.nvim_get_current_buf()
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
print(vim.inspect(queries))
local out = {}
for i, query in pairs(queries) do
    local qparsed = vim.treesitter.query.parse(ft, query)
    -- print("i", i, "-------", vim.inspect(qparsed))
    for id, node, _ in qparsed:iter_captures(root, bufnr, 0, -1) do
        cpt = qparsed.captures[id]
        -- print(cpt)
        txt = vim.treesitter.get_node_text(node, bufnr)
        node_type = node:type()
        print(node:type())
        if i == "toc_comments" then
            txt = string.sub(txt, defaults[ft].cmslen + 1)
        end
        local row1, _, row2, _ = node:range()
        -- Verificar que no sea comentario de bloque (al menos con javascript funciona)
        if (i == "toc_comments" and row1 == row2) or i ~= "toc_comments" then
            table.insert(out, { type = i, node_type = node_type, line = row1 + 1, text = vim.trim(txt) })
        end
    end
end

table.sort(out, function(a, b)
    return a.line < b.line
end)

print("------------")
print(vim.inspect(out))
