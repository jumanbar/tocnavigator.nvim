local M = {}

M.r = {

    toc_comments = [[
        ((comment) @toc_comment (#match? @toc_comment "[-=]{4,}\s*"))
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
            (#match? @toc_comment "[-=]{4,}\s*")
        )
    ]],

    functions = [[
        (function_declaration
            name: (identifier) @fun )
    ]]

}

M.javascript = {

    toc_comments = [[
        ((comment) @toc_comment (#match? @toc_comment "[-=]{4,}\s*"))
    ]],

    functions = [[
        (function_declaration
            name: (identifier) @fun )
    ]]

}

M.python = {

    toc_comments = [[
        ((comment) @toc_comment (#match? @toc_comment "[-=]{4,}\s*"))
    ]],

    functions = [[
        (function_definition
            name: (identifier) @fun)
    ]]
}


return M

