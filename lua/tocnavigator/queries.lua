local M = {}

M.r = {

    toc_comments = [[
        ((comment) @toc_comment (#match? @toc_comment "[-=]{4,}\s*$"))
    ]],

    functions = [[
        (left_assignment
          name: (identifier) @fun
          value: (function_definition) @def)
    ]]

}

M.lua = {

    toc_comments  = [[
        (comment content:
            (comment_content) @toc_comment
            (#match? @toc_comment "[-=]{4,}\s*$")
        )
    ]],

    functions = [[
        (function_declaration
            name: (identifier) @fun )
    ]]

}

M.php = {

    toc_comments = [[
        ((comment) @toc_comment (#match? @toc_comment "[-=]{4,}\s*$"))
    ]],

    functions = [[
        (function_definition
            name: (name) @fun )
    ]]

}

M.javascript = {

    toc_comments = [[
        ((comment) @toc_comment (#match? @toc_comment "[-=]{4,}\s*$"))
    ]],

    functions = [[
        (function_declaration
            name: (identifier) @fun )
    ]]

}

M.python = {

    toc_comments = [[
        ((comment) @toc_comment (#match? @toc_comment "[-=]{4,}\s*$"))
    ]],

    functions = [[
        (function_definition
            name: (identifier) @fun)
    ]]
}

M.markdown = {
    headings = [[
        ([
          (section (atx_heading) @heading)

          (setext_heading
            heading_content: (paragraph) @subth
            (_) @suby)
        ])
    ]]
}

return M

