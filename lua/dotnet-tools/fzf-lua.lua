local M = {}

local fzf_lua = require("fzf-lua")

-- shows the results for buids and tests in a telescope picker
function M.show_results(title, test_results_table)
    fzf_lua.fzf_exec(test_results_table, {
        winopts = {
            win_height = 0.8,
            win_width = 0.8,
            win_border = true,
            win_title = title,
        },
        preview = {
            preview_title = "Preview",
            previewer = function(entry)
                return entry.value
            end,
        },
    })
end

return M
