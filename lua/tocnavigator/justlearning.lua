-- Comentario doc ======
local q = require("lua.tocnavigator.queries")

local defaults = {
    after = "normal zt",
    r = {
        toc_comments = true,
        functions = true,
    },
    markdown = {
        title = true
    },
    lua = {
        toc_comments = true,
        functions = true,
    },
    javascript = {
        toc_comments = true,
        functions = true,
    },
    python = {
        toc_comments = true,
        functions = true,
    }
}

local function totora()
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

local out = {}
for i, query in pairs(queries) do
    local qparsed = vim.treesitter.query.parse(ft, query)
    -- print("i", i, "-------", vim.inspect(qparsed))
    for _, node, _ in qparsed:iter_captures(root, bufnr, 0, -1) do
        local txt = vim.treesitter.get_node_text(node, bufnr)
        local row1, _, row2, _ = node:range()
        -- Verificar que no sea comentario de bloque (al menos con javascript funciona)
        if row1 == row2 then
            table.insert(out, { type = i, line = row1 + 1, text = txt })
        end
    end
end

table.sort(out, function(a, b)
    return a.line < b.line
end)

print("------------")
print(vim.inspect(out))
