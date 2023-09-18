-- local M = {}

-- Variables =========
local buf, toc
local position = 1

Win = nil
Win_orig = nil

-- vim.cmd [[ hi def link WhidHeader      Number ]]
vim.cmd [[ hi def link WhidSubHeader   Identifier ]]

--- get_toc ========
local function get_toc(bufnr)
    local out = {}
    local lineas = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local cms = vim.bo[bufnr].commentstring

    if cms == "" then
        return out
    end

    local cmt0 = string.match(cms, "^(.*)%s")
    local cmt = string.gsub(cmt0, '(.)', '%%%1')
    local re_heading = vim.regex("^\\s*" .. cmt0 .. ".*[-=]\\{4,\\}")
    local heading = "..."
    local prefix = "^%s*" .. cmt .. "+%s*"
    local suffix = "%s*[-=]+"
    local pos = vim.api.nvim_win_get_cursor(Win_orig)[1]

    local j = 1
    for i, line in ipairs(lineas) do
        if re_heading:match_str(line) then
            heading = vim.trim(line:gsub(prefix, ""):gsub(suffix, ""))
            table.insert(out, { line = i, heading = heading })
            if j > 1 and pos < i and pos >= out[j - 1].line then
                position = j - 1
            end
            j = j + 1
        end
    end

    if pos >= out[#out].line then
        position = #out
    end

    return out
end

local function pad(str, fill, n)
    local dif = n - string.len(str)

    if dif > 0 then
        str = string.rep(fill, dif) .. str
    end

    return str
end

local function open_window(width, width_num)
    buf = vim.api.nvim_create_buf(false, true)
    local border_buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'toggle_toc_navigator')

    local width_curr = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    width = width + 10 + width_num
    if width > width_curr then
        width = width_curr
    end

    -- Width minimum: '╔═ Table of Contents =╗'
    if width < 23 then
        width = 23
    end


    local win_height = math.ceil(height * 0.7 - 4)
    local win_width = width

    if #toc < win_height then
        win_height = #toc
    end

    local row = math.ceil((height - win_height) * 0.6 - 1)
    local col = math.ceil((width_curr - win_width) / 2)


    local border_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width + 2,
        height = win_height + 4,
        row = row - 1,
        col = col - 1
    }

    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row + 1,
        col = col
    }

    -- Width of ' Table of Contents ' = 19
    local mitad = math.floor((win_width - 19) / 2)
    local border_lines = {
        '╔' .. string.rep('═', mitad) .. ' Table of Contents ' .. string.rep('=', win_width - 19 - mitad) .. '╗' }
    local middle_line = '║' .. string.rep(' ', win_width) .. '║'
    for i = 1, win_height + 2 do
        table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
    vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    -- Create new window that will contain the real buffer
    local border_win = vim.api.nvim_open_win(border_buf, true, border_opts)

    -- Create the new window
    Win = vim.api.nvim_open_win(buf, true, opts)

    vim.api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

    vim.api.nvim_win_set_option(Win, 'cursorline', true) -- it highlight line with the cursor on it

    vim.api.nvim_buf_add_highlight(buf, -1, 'WhidHeader', 0, 0, -1)
end

local function fill_view(width_num)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    local toc_copy = vim.deepcopy(toc)

    if #toc_copy == 0 then table.insert(toc_copy, '') end -- add  an empty line to preserve layout if there is no results
    for k in pairs(toc_copy) do
        toc_copy[k] = '    ' .. pad(tostring(toc_copy[k].line), ' ', width_num) .. '  ' .. toc_copy[k].heading
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, toc_copy)

    vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
    vim.api.nvim_win_set_cursor(Win, { position, 0 })
    vim.api.nvim_buf_add_highlight(buf, -1, 'WhidSubHeader', position - 1, 0, -1)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end


local function close_window()
    vim.api.nvim_win_close(Win, true)
end

local function go_to_line()
    local i = toc[position].line
    close_window()
    vim.api.nvim_win_set_cursor(Win_orig, { i, 0 })
end

--- upadte_pos ========
local function update_pos()
    local toc_pos = vim.api.nvim_win_get_cursor(Win)
    vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, 'WhidSubHeader', toc_pos[1] - 1, 0, -1)
    position = toc_pos[1]
end

--- toggle_toc_navigator ========
local function toggle_toc_navigator()
    position = 1
    Win_orig = vim.api.nvim_get_current_win()
    toc = get_toc(vim.api.nvim_get_current_buf())

    if #toc == 0 then
        print('TOCNavigator aborted: No TOC available')
        return
    end

    local max_width = 0
    local heading_width = 0
    for k in pairs(toc) do
        heading_width = string.len(toc[k].heading)
        if heading_width > max_width then
            max_width = heading_width
        end
    end

    local num_width = string.len(tostring(toc[#toc].line))

    open_window(max_width, num_width)
    fill_view(num_width)

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "gg",
        "gg<Cmd>lua require('tocnavigator').update_pos()<CR>",
        { silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "G",
        "G<Cmd>lua require('tocnavigator').update_pos()<CR>",
        { silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "k",
        "k<Cmd>lua require('tocnavigator').update_pos()<CR>",
        { silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "j",
        "j<Cmd>lua require('tocnavigator').update_pos()<CR>",
        { silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "<C-c>",
        "<Cmd>lua require('tocnavigator').close_window()<CR>",
        { silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "<Esc>",
        "<Cmd>lua require('tocnavigator').close_window()<CR>",
        { silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "q",
        "<Cmd>lua require('tocnavigator').close_window()<CR>",
        { silent = true }
    )

    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "<CR>",
        "<Cmd>lua require('tocnavigator').go_to_line()<CR>",
        { silent = true }
    )
end

return {
    toggle_toc_navigator = toggle_toc_navigator,
    fill_view = fill_view,
    update_pos = update_pos,
    go_to_line = go_to_line,
    close_window = close_window
}
