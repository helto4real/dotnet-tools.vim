local M = {}

-- shows the results for buids and tests in a telescope picker
function M.show_results(_, pick_results)
    local opts = {
        finder = function()
            return pick_results
        end,
    }

    Snacks.picker.pick(opts)
end

return M
